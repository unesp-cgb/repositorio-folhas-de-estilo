<?xml version="1.0" encoding="UTF-8"?>

<!--    Folha de estilo XSLT para a conversão de registros da Web of Science           

        Última atualização: 2018-09-26

        ==================================
        Repositório Insitucional da UNESP
        
        Fabrício Silva Assumpção
        Coordenadoria Geral de Bibliotecas (CGB)
        fabricio@reitoria.unesp.br
        ==================================                          -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns2="http://woksearch.v3.wokmws.thomsonreuters.com"
    xmlns:functx="http://www.functx.com"
    xmlns:wos="http://scientific.thomsonreuters.com/schema/wok5.4/public/FullRecord"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:output indent="yes" encoding="UTF-8" />
    
    <!-- Funções não nativas da XSLT obtidas a partir de http://www.xsltfunctions.com/ -->
        
    <xsl:function name="functx:contains-any-of" as="xs:boolean" 
        xmlns:functx="http://www.functx.com" >
        <xsl:param name="arg" as="xs:string?"/> 
        <xsl:param name="searchStrings" as="xs:string*"/> 
        
        <xsl:sequence select=" 
            some $searchString in $searchStrings
            satisfies contains($arg,$searchString)
            "/>
    </xsl:function>
    
    <xsl:function name="functx:capitalize-first" as="xs:string?" 
        xmlns:functx="http://www.functx.com" >
        <xsl:param name="arg" as="xs:string?"/> 
        
        <xsl:sequence select=" 
            concat(upper-case(substring($arg,1,1)),
            substring($arg,2))
            "/>
    </xsl:function>
    
	<xsl:function name="functx:replace-first" as="xs:string"
		xmlns:functx="http://www.functx.com">
		<xsl:param name="arg" as="xs:string?"/>
		<xsl:param name="pattern" as="xs:string"/>
		<xsl:param name="replacement" as="xs:string"/>
		
		<xsl:sequence select="
			replace($arg, concat('(^.*?)', $pattern),
			concat('$1',$replacement))
			"/>
	</xsl:function>
	
    <!-- Início da folha de estilo -->
    
    <xsl:template match="/">
        <records>
        	
        	<!-- O "caminho" abaixo deve ser atualizado toda vez:
        	Para o primeiro arquivo, o caminho deve ser: /soap:Envelope/soap:Body/ns2:searchResponse/return/records/records/REC
        	Para os demais arquivos, o caminho deve ser: /soap:Envelope/soap:Body/ns2:retrieveResponse/return/records/records/REC -->
        	
        	<xsl:for-each select="/REC">
                <dublin_core schema="dc">
                    <xsl:call-template name="record" />
                </dublin_core>
            </xsl:for-each>
        </records>
    </xsl:template>
    
    <xsl:template name="record">
     
    	<!-- dc.identifier.citation -->
    
    	<dcvalue element="identifier" qualifier="citation">
            
            <!-- Título do periódico -->
            
            <xsl:call-template name="CamelCase">
                <xsl:with-param name="text">
                    <xsl:value-of select="static_data/summary/titles/title[@type='source']"/>
                </xsl:with-param>
            </xsl:call-template>
            
            <!-- Local de publicação -->
            
            <xsl:if test="static_data/summary/publishers/publisher[1]/address_spec/city[1]">
                <xsl:text>. </xsl:text>
                <xsl:call-template name="CamelCase">
                    <xsl:with-param name="text">
                        <xsl:value-of select="static_data/summary/publishers/publisher[1]/address_spec/city[1]" />
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            
            <!-- Publicador -->
            
            <xsl:if test="static_data/summary/publishers/publisher[1]/address_spec/city[1]">
                <xsl:text>: </xsl:text>
                <xsl:call-template name="CamelCase">
                    <xsl:with-param name="text">
                        <xsl:value-of select="static_data/summary/publishers/publisher[1]/names/name/display_name" />
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>

            <!-- Volume -->
            
            <xsl:if test="static_data/summary/pub_info/@vol">
                <xsl:text>, v. </xsl:text>
                <xsl:value-of select="static_data/summary/pub_info/@vol"/>
            </xsl:if>
            
            <!-- Número -->
            
            <xsl:if test="static_data/summary/pub_info/@issue">
                <xsl:text>, n. </xsl:text>
                <xsl:value-of select="static_data/summary/pub_info/@issue"/>
            </xsl:if>
            
            <!-- Paginação inicial e final -->
            
            <xsl:choose>
                <xsl:when test="string-length(static_data/summary/pub_info/page) &gt; 1">
                    <xsl:text>, p. </xsl:text>
                    <xsl:value-of select="static_data/summary/pub_info/page" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="static_data/summary/pub_info/page/@page_count" />
                    <xsl:text> p.</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            
            <!-- Ano de publicação -->
            
            <xsl:if test="static_data/summary/pub_info/@pubyear">
                <xsl:text>, </xsl:text>
                <xsl:value-of select="static_data/summary/pub_info/@pubyear"/>
            </xsl:if>
            
            <xsl:text>.</xsl:text>
        </dcvalue>
     
        <!-- dc.contributor.author -->
        
        <xsl:for-each select="static_data/summary/names/name">
            <dcvalue element="contributor" qualifier="author">
            	
            	<xsl:variable name="authorsName">
	                <xsl:choose>
	                    <xsl:when test="first_name and last_name">
	                        <xsl:choose>
	                            <xsl:when test="last_name = upper-case(last_name)">
	                                <xsl:call-template name="CamelCase">
	                                    <xsl:with-param name="text">
	                                        <xsl:value-of select="last_name"/>
	                                    </xsl:with-param>
	                                </xsl:call-template>
	                            </xsl:when>
	                            <xsl:otherwise>
	                                <xsl:value-of select="last_name"/>
	                            </xsl:otherwise>
	                        </xsl:choose>
	                        
	                        <xsl:text>, </xsl:text>
	                        
	                        <xsl:choose>
	                            <xsl:when test="string-length(first_name) = 1">
	                                <xsl:value-of select="first_name"/>
	                                <xsl:text>.</xsl:text>
	                            </xsl:when>
	                            
	                            <xsl:when test="
	                                string-length(first_name) = 2 and 
	                                first_name = upper-case(first_name) and
	                                not(ends-with(first_name,'.'))">
	                                <xsl:value-of select="substring(first_name,1,1)"/>
	                                <xsl:text>. </xsl:text>
	                                <xsl:value-of select="substring(first_name,2,1)"/>
	                                <xsl:text>.</xsl:text>
	                            </xsl:when>
	                            
	                            <xsl:otherwise>
	                                <xsl:value-of select="first_name"/>
	                            </xsl:otherwise>
	                        </xsl:choose>
	                    </xsl:when>
	                    
	                    <xsl:otherwise>
	                        <xsl:value-of select="display_name"/>
	                    </xsl:otherwise>
	                </xsl:choose>
            	</xsl:variable>
                
                <xsl:choose>
                	<xsl:when test="starts-with($authorsName,'da ')">
                		<xsl:value-of select="functx:replace-first($authorsName,'da ','')"/>
                		<xsl:text> da</xsl:text>
                	</xsl:when>
                	<xsl:when test="starts-with($authorsName,'de ')">
                		<xsl:value-of select="functx:replace-first($authorsName,'de ','')"/>
                		<xsl:text> de</xsl:text>
                	</xsl:when>
                	<xsl:when test="starts-with($authorsName,'do ')">
                		<xsl:value-of select="functx:replace-first($authorsName,'do ','')"/>
                		<xsl:text> do</xsl:text>
                	</xsl:when>
                	<xsl:when test="starts-with($authorsName,'dos ')">
                		<xsl:value-of select="functx:replace-first($authorsName,'dos ','')"/>
                		<xsl:text> dos</xsl:text>
                	</xsl:when>
                	<xsl:otherwise>
                		<xsl:value-of select="$authorsName"/>
                	</xsl:otherwise>
                </xsl:choose>
            	
                <!-- Regras para a atribuição da afiliação -->
                
                <!-- Extrai ID (@addr_no) da afiliação do autor -->
                
                <!-- ID da primeira afiliação -->
                
                <xsl:variable name="first_affiliation_number_author">
                    <xsl:choose>
                        <xsl:when test="contains(./@addr_no,' ')">
                            <xsl:value-of select="substring-before(./@addr_no,' ')" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="./@addr_no" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <!-- ID da segunda afiliação -->
                
                <xsl:variable name="second_affiliation_number_author">
                    <xsl:choose>
                        <xsl:when test="contains(./@addr_no,' ') and contains(substring-after(./@addr_no,' '),' ')">
                            <xsl:value-of select="substring-before(substring-after(./@addr_no,' '),' ')" />
                        </xsl:when>
                        <xsl:when test="contains(./@addr_no,' ')">
                            <xsl:value-of select="substring-after(./@addr_no,' ')" />
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                
                <!-- ID da terceira afiliação -->
                
                <xsl:variable name="third_affiliation_number_author">
                    <xsl:choose>
                        <xsl:when test="contains(substring-after(substring-after(./@addr_no,' '),' '),' ')">
                            <xsl:value-of select="substring-before(substring-after(substring-after(./@addr_no,' '),' '),' ')" />
                        </xsl:when>
                        <xsl:when test="not(contains(substring-after(substring-after(./@addr_no,' '),' '),' '))">
                            <xsl:value-of select="substring-after(substring-after(./@addr_no,' '),' ')" />
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                
                <!-- Reúne todas as afiliações do autor por meio da correspondência dos IDs -->
                
                <xsl:variable name="affiliations">
                    <xsl:value-of select="lower-case(ancestor::node()[3]/fullrecord_metadata/addresses/address_name/address_spec[@addr_no = $first_affiliation_number_author]/full_address)" />
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="lower-case(ancestor::node()[3]/fullrecord_metadata/addresses/address_name/address_spec[@addr_no = $second_affiliation_number_author]/full_address)" />
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="lower-case(ancestor::node()[3]/fullrecord_metadata/addresses/address_name/address_spec[@addr_no = $third_affiliation_number_author]/full_address)" />
                </xsl:variable>
                
                <!-- Busca nas afiliações do autor algum indicativo de que ele é da UNESP.
                    Se algum indicativo for encontrado, é acrescentado " [UNESP]" após o nome do autor -->
                
                <xsl:if test="functx:contains-any-of($affiliations,(
                    'unesp',
                    'univ estadual paulista',
                    'universidade estadual paulista',
                    'universidade estadual de são paulo',
                    'universidade estadual de sao paulo',
                    'paulista state univ',
                    'sao paulo state univ',
                    'são paulo state univ',
                    'state univ sao paulo',
                    'faculdade de medicina de botucatu',
                    'botucatu medical school',
                    'universidad estadual paulista',
                    'universidade estadua paulista',
                    'universidade estadual de paulista',
                    'state univ são paulo',
                    's. paulo state univ',
                    'so paulo state university',
                    'univ estad paulista',
                    'univ. estadual paulista',
                    'estadual paulista‏',
                    'ibilce',
                    'mesquita filho'))">
                    <xsl:text> [UNESP]</xsl:text>
                </xsl:if>
                
            </dcvalue>
        </xsl:for-each>

	<!-- dc.author.orcid -->
        <xsl:for-each select="static_data/contributors/contributor/name">
	    <dcvalue element="author" qualifier="orcid">
                <xsl:variable name="authorsORCID">
		    <xsl:if test="./@orcid_id">
		        <xsl:value-of select="./@orcid_id"/>   
			<xsl:text>[</xsl:text>
                        <xsl:value-of select="first_name"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="last_name"/>  
                        <xsl:text>]</xsl:text>
	            </xsl:if>
                </xsl:variable>
		      
		<xsl:value-of select="$authorsORCID"/>
		      
            </dcvalue>
        </xsl:for-each>	    

        <!-- dc.contributor.institution -->

        <xsl:for-each select="static_data/fullrecord_metadata/addresses/address_name/address_spec">
            <dcvalue element="contributor" qualifier="institution">
                <xsl:choose>
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('unesp',
                        'univ estadual paulista',
                        'universidade estadual paulista',
                        'universidade estadual de são paulo',
                        'universidade estadual de sao paulo',
                        'paulista state univ',
                        'sao paulo state univ',
                        'são paulo state univ',
                        'state univ sao paulo',
                        'state univ são paulo',
                        'faculdade de medicina de botucatu',
                        'botucatu medical school',
                        'universidad estadual paulista',
                        'universidade estadua paulista',
                        'universidade estadual de paulista',
                        's. paulo state univ',
                        'so paulo state university',
                        'univ estad paulista',
                        'univ. estadual paulista',
                        'estadual paulista‏',
                        'ibilce',
                        'mesquita filho'))">
                        <xsl:text>Universidade Estadual Paulista (UNESP)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('unicamp',
                        'univ campinas',
                        'univ estadual campinas',
                        'universidade estadual de campinas',
                        'universidade de campinas',
                        'campinas univ',
                        'campinas state univ',
                        'university of campinas',
                        'state university of campinas',
                        'campinas estadual univ'))">
                        <xsl:text>Universidade Estadual de Campinas (UNICAMP)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('univ de sao paulo',
                        'usp',
                        'universidade de são paulo',
                        'universidade de sao paulo',
                        'university of sao paulo',
                        'sao paulo univ',
                        'são paulo univ',
                        'univ. of são paulo',
                        'univ. of sao paulo',
                        'university of são paulo',
                        'university of sao paulo',
                        'universidade de so paulo',
                        'universidade de, são paulo',
                        'univ sao paulo',
                        'sao paulo university'))">
                        <xsl:text>Universidade de São Paulo (USP)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('universidade federal de são carlos',
                        'universidade federal de sao carlos',
                        'ufscar',
                        'univ fed de são carlos',
                        'univ fed de sao carlos',
                        'univ fed são carlos',
                        'univ. federal de são carlos',
                        'sao carlos fed univ',
                        'são carlos fed univ',
                        'federal university of são carlos',
                        'federal university of sao carlos',
                        'univ fed sao carlos'))">
                        <xsl:text>Universidade Federal de São Carlos (UFSCar)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('universidade estadual de londrina',
                        'univ estadual de londrina',
                        'univ estadual londrina',
                        'londrina state university',
                        'state university of londrina',
                        'univ est de londrina',
                        'univ est londrina'))">
                        <xsl:text>Universidade Estadual de Londrina (UEL)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('universidade federal de mato grosso do sul',
                        'univ fed mato grosso do sul',
                        'univ fed do mato grosso do sul',
                        'mato grosso do sul univ fed',
                        'univ. federal de mato grosso do sul',
                        'ufms'))">
                        <xsl:text>Universidade Federal de Mato Grosso do Sul (UFMS)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('universidade estadual de mato grosso do sul',
                        'univ estadual de mato grosso do sul',
                        'univ est de mato grosso do sul',
                        'mato grosso do sul univ est',
                        'univ estadual mato grosso do sul',
                        'univ est mato grosso do sul',
                        'uems'))">
                        <xsl:text>Universidade Estadual de Mato Grosso do Sul (UEMS)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('universidade federal do rio de janeiro',
                        'univ fed do rio de janeiro',
                        'univ fed rio de janeiro',
                        'univ. fed. rio de janeiro',
                        'univ. federal do rio de janeiro',
                        'ufrj'))">
                        <xsl:text>Universidade Federal do Rio de Janeiro (UFRJ)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('universidade federal de são paulo',
                        'universidade federal de sao paulo',
                        'univ fed de são paulo',
                        'univ fed são paulo',
                        'univ. fed. são paulo',
                        'univ fed de sao paulo',
                        'univ fed sao paulo',
                        'univ. fed. sao paulo',
                        'federal university of são paulo',
                        'federal university of sao paulo',
                        'unifesp'))">
                        <xsl:text>Universidade Federal de São Paulo (UNIFESP)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('universidade do estado do rio de janeiro',
                        'univ est rio de janeiro',
                        'uerj'))">
                        <xsl:text>Universidade do Estado do Rio de Janeiro (UERJ)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('universidade federal do abc',
                        'univ. federal do abc',
                        'univ federal do abc',
                        'univ fed abc',
                        'ufabc'))">
                        <xsl:text>Universidade Federal do ABC (UFABC)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('empresa brasileira de pesquisa agropecuária',
                        'empresa brasileira de pesquisa agropecuaria',
                        'embrapa'))">
                        <xsl:text>Empresa Brasileira de Pesquisa Agropecuária (EMBRAPA)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('universidade federal do paraná',
                        'univ. federal do paraná',
                        'ufpr'))">
                        <xsl:text>Universidade Federal do Paraná (UFPR)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('universidade estadual de maringá',
                        'univ. estadual de maringá',
                        'universidade estadual de maringa',
                        'univ. estadual de maringa',
                        'uem'))">
                        <xsl:text>Universidade Estadual de Maringá (UEM)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('universidade federal de minas gerais',
                        'univ. federal de minas gerais',
                        'federal university of minas gerais',
                        'ufmg'))">
                        <xsl:text>Universidade Federal de Minas Gerais (UFMG)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('universidade federal de viçosa',
                        'universidade federal de vicosa',
                        'univ. federal de vicosa',
                        'univ. federal de viçosa',
                        'ufv'))">
                        <xsl:text>Universidade Federal de Viçosa (UFV)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('universidade federal de santa catarina',
                        'univ. federal de santa catarina',
                        'federal university of santa catarina',
                        'ufsc'))">
                        <xsl:text>Universidade Federal de Santa Catarina (UFSC)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('universidade estadual de ponta grossa',
                        'univ. estadual de ponta grossa',
                        'univ. est. de ponta grossa',
                        'uepg'))">
                        <xsl:text>Universidade Estadual de Ponta Grossa (UEPG)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('universidade federal da bahia',
                        'univ. federal da bahia',
                        'univ federal da bahia',
                        'univ. fed da bahia',
                        'federal university of bahia',
                        'fed. univ. of bahia',
                        'ufba'))">
                        <xsl:text>Universidade Federal da Bahia (UFBA)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('universidade federal da paraíba',
                        'univ. federal da paraíba',
                        'univ federal da paraíba',
                        'fed. univ. of paraiba',
                        'fereral university of paraiba',
                        'ufpb'))">
                        <xsl:text>Universidade Federal da Paraíba (UFPB)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('universidade federal de goiás',
                        'univ. federal de goiás',
                        'univ. federal de goias',
                        'univ federal de goias',
                        'federal university of goiás',
                        'fed univ of goiás',
                        'universidade federal de goias'))">
                        <xsl:text>Universidade Federal de Goiás (UFG)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('universidade de brasília',
                        'univ. de brasília',
                        'universidade de brasilia',
                        'univ. de brasilia',
                        'sigla'))">
                        <xsl:text>Universidade de Brasília (UnB)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('universidade federal de lavras',
                        'univ. federal de lavras',
                        'univ federal de lavras',
                        'ufla'))">
                        <xsl:text>Universidade Federal de Lavras (UFLA)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('universidade federal de pernambuco',
                        'univ federal de pernambuco',
                        'univ. federal de pernambuco',
                        'federal university of pernambuco',
                        'ufpe'))">
                        <xsl:text>Universidade Federal de Pernambuco (UFPE)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('universidade federal de sergipe',
                        'univ. federal de sergipe',
                        'univ federal de sergipe',
                        'federal university of sergipe',
                        'ufs'))">
                        <xsl:text>Universidade Federal de Sergipe (UFS)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('universidade federal de uberlândia',
                        'universidade federal de uberlandia',
                        'univ. federal de uberlândia',
                        'univ federal de uberlândia',
                        'federal university of uberlândia',
                        'federal university of uberlandia'))">
                        <xsl:text>Universidade Federal de Uberlândia (UFU)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('universidade federal do espírito santo',
                        'univ. federal do espírito santo',
                        'univ federal do espírito santo',
                        'universidade federal do espirito santo',
                        'univ. federal do espirito santo',
                        'univ federal do espirito santo'))">
                        <xsl:text>Universidade Federal do Espírito Santo (UFES)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('universidade federal do pará',
                        'univ. federal do pará',
                        'univ federal do pará',
                        'federal university of pará',
                        'ufpa'))">
                        <xsl:text>Universidade Federal do Pará (UFPA)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),
                        ('universidade federal fluminense',
                        'univ. federal fluminense',
                        'univ federal fluminense'))">
                        <xsl:text>Universidade Federal Fluminense (UFF)</xsl:text>
                    </xsl:when>
                    
                    <xsl:otherwise>
                        <xsl:value-of select="organizations/organization[1]"/>
                    </xsl:otherwise>
                    
                </xsl:choose>
            </dcvalue>
        </xsl:for-each>
     
        <xsl:if test="
            not(functx:contains-any-of(lower-case(string-join(static_data/fullrecord_metadata/addresses/address_name/address_spec,' ')),
            ('unesp',
            'univ estadual paulista',
            'universidade estadual paulista',
            'universidade estadual de são paulo',
            'universidade estadual de sao paulo',
            'paulista state univ',
            'sao paulo state univ',
            'são paulo state univ',
            'state univ sao paulo',
            'state univ são paulo',
            'faculdade de medicina de botucatu',
            'botucatu medical school',
            'universidad estadual paulista',
            'universidade estadua paulista',
            'universidade estadual de paulista',
            's. paulo state univ',
            'so paulo state university',
            'univ estad paulista',
            'univ. estadual paulista',
            'estadual paulista‏',
            'ibilce',
            'mesquita filho')))">
            <dcvalue element="contributor" qualifier="institution">
                <xsl:text>Universidade Estadual Paulista (UNESP)</xsl:text>
            </dcvalue>
        </xsl:if>
     
        <!-- dc.date.issued -->
        
        <dcvalue element="date" qualifier="issued">
            <xsl:choose>
                <xsl:when test="static_data/summary/pub_info/@sortdate">
                    <xsl:value-of select="static_data/summary/pub_info/@sortdate" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="static_data/summary/pub_info/@pubyear" />
                </xsl:otherwise>
            </xsl:choose>
        </dcvalue>
     
        <!-- dc.description.abstract -->
        
        <xsl:for-each select="static_data/fullrecord_metadata/abstracts/abstract/abstract_text">
            <dcvalue element="description" qualifier="abstract" language="en">
                <xsl:value-of select="normalize-space(.)"/>
            </dcvalue>
        </xsl:for-each>
     
        <!-- dc.description.affiliation -->
        
        <xsl:for-each select="static_data/fullrecord_metadata/addresses/address_name/address_spec/full_address">
            <dcvalue element="description" qualifier="affiliation">   
                <xsl:value-of select="normalize-space(.)" />
            </dcvalue>
        </xsl:for-each>
     
        <xsl:if test="not(static_data/fullrecord_metadata/addresses/address_name/address_spec)">
            <dcvalue element="description" qualifier="affiliation">
                <xsl:value-of select="normalize-space(static_data/item/reprint_contact/address_spec/full_address)"/>
            </dcvalue>
        </xsl:if>
     
        <!-- dc.description.affiliationUnesp -->
     
        <xsl:for-each select="static_data/fullrecord_metadata/addresses/address_name/address_spec/full_address">
            <xsl:if test="functx:contains-any-of(lower-case(.),
                ('unesp',
                'univ estadual paulista',
                'universidade estadual paulista',
                'universidade estadual de são paulo',
                'universidade estadual de sao paulo',
                'paulista state univ',
                'sao paulo state univ',
                'são paulo state univ',
                'state univ sao paulo',
                'state univ são paulo',
                'faculdade de medicina de botucatu',
                'botucatu medical school',
                'universidad estadual paulista',
                'universidade estadua paulista',
                'universidade estadual de paulista',
                's. paulo state univ',
                'so paulo state university',
                'univ estad paulista',
                'univ. estadual paulista',
                'estadual paulista‏',
                'ibilce',
                'mesquita filho'))"> 
                <dcvalue element="description" qualifier="affiliationUnesp">  
                    <xsl:value-of select="normalize-space(.)" />
                </dcvalue>
            </xsl:if>
        </xsl:for-each>
     
        <xsl:if test="
            not(static_data/fullrecord_metadata/addresses/address_name/address_spec)
            and functx:contains-any-of(lower-case(static_data/item/reprint_contact/address_spec/full_address),
            ('unesp',
            'univ estadual paulista',
            'universidade estadual paulista',
            'universidade estadual de são paulo',
            'universidade estadual de sao paulo',
            'paulista state univ',
            'sao paulo state univ',
            'são paulo state univ',
            'state univ sao paulo',
            'state univ são paulo',
            'faculdade de medicina de botucatu',
            'botucatu medical school',
            'universidad estadual paulista',
            'universidade estadua paulista',
            'universidade estadual de paulista',
            's. paulo state univ',
            'so paulo state university',
            'univ estad paulista',
            'univ. estadual paulista',
            'estadual paulista‏',
            'ibilce',
            'mesquita filho'))
            ">
            <dcvalue element="description" qualifier="affiliationUnesp">
                <xsl:value-of select="normalize-space(static_data/item/reprint_contact/address_spec/full_address)"/>
            </dcvalue>
        </xsl:if>
     
        <!-- dc.format.extent -->
        
        <dcvalue element="format" qualifier="extent">
            <xsl:choose>
                <xsl:when test="string-length(static_data/summary/pub_info/page) &gt; 1">
                    <xsl:value-of select="static_data/summary/pub_info/page" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="static_data/summary/pub_info/page/@page_count" />
                </xsl:otherwise>
            </xsl:choose>
        </dcvalue>
     
        <!-- dc.description.sponsorship -->
        
        <xsl:for-each select="static_data/fullrecord_metadata/fund_ack/grants/grant/grant_agency">
            <dcvalue element="description" qualifier="sponsorship">
                <xsl:choose>
                    <xsl:when test="functx:contains-any-of(lower-case(.),(
                        'fapesp',
                        'fundação de amparo à pesquisa do estado de são paulo',
                        'fundacao de amparo a pesquisa do estado de sao paulo',
                        'fundación de apoyo a la investigación del estado de são paulo',
                        'state of são paulo research foundation',
                        'sao paulo research foundation',
                        'são paulo state research foundation',
                        'sao paulo state research foundation'))">
                        <xsl:text>Fundação de Amparo à Pesquisa do Estado de São Paulo (FAPESP)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),(
                        'cnpq',
                        'conselho nacional de desenvolvimento cientifico e tecnologico',
                        'cons. nac. desenvolv. cient. tecnol.',
                        'conselho nacional de desenvolvimento científico e tecnológico'))">
                        <xsl:text>Conselho Nacional de Desenvolvimento Científico e Tecnológico (CNPq)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),(
                        'capes',
                        'coordenacao de aperfeicoamento de pessoal de nivel superior',
                        'coordenação de aperfeiçoamento de pessoal de nível superior'))">
                        <xsl:text>Coordenação de Aperfeiçoamento de Pessoal de Nível Superior (CAPES)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),(
                        'fundunesp',
                        'fundacao para o desenvolvimento da unesp',
                        'fundação para o desenvolvimento da unesp'))">
                        <xsl:text>Fundação para o Desenvolvimento da UNESP (FUNDUNESP)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),(
                        'faperj',
                        'fundacao de amparo a pesquisa do estado do rio de janeiro',
                        'fundação de amparo à pesquisa do estado do rio de janeiro',
                        'carlos chagas filho'))">
                        <xsl:text>Fundação de Amparo à Pesquisa do Estado do Rio de Janeiro (FAPERJ)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="functx:contains-any-of(lower-case(.),(
                        'fapemig',
                        'fundacao de amparo a pesquisa do estado de minas gerais',
                        'fundação de amparo à pesquisa do estado de minas gerais'))">
                        <xsl:text>Fundação de Amparo à Pesquisa do Estado de Minas Gerais (FAPEMIG)</xsl:text>
                    </xsl:when>
                    
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(.)" />
                    </xsl:otherwise>
                
                </xsl:choose>
            </dcvalue>
        </xsl:for-each>
     
        <!-- dc.description.sponsorshipId -->
        
        <xsl:for-each select="static_data/fullrecord_metadata/fund_ack/grants/grant/grant_ids/grant_id">
            <dcvalue element="description" qualifier="sponsorshipId">
                <xsl:choose>
                    <xsl:when test="
                        functx:contains-any-of(lower-case(ancestor::node()[2]/grant_agency),(
                        'fapesp',
                        'fundação de amparo à pesquisa do estado de são paulo',
                        'fundacao de amparo a pesquisa do estado de sao paulo',
                        'fundación de apoyo a la investigación del estado de são paulo',
                        'state of são paulo research foundation',
                        'sao paulo research foundation',
                        'são paulo state research foundation',
                        'sao paulo state research foundation'))">
                        <xsl:text>FAPESP: </xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="
                        functx:contains-any-of(lower-case(ancestor::node()[2]/grant_agency),(
                        'cnpq',
                        'conselho nacional de desenvolvimento cientifico e tecnologico',
                        'cons. nac. desenvolv. cient. tecnol.',
                        'conselho nacional de desenvolvimento científico e tecnológico'))">
                        <xsl:text>CNPq: </xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="
                        functx:contains-any-of(lower-case(ancestor::node()[2]/grant_agency),(
                        'capes',
                        'coordenacao de aperfeicoamento de pessoal de nivel superior',
                        'coordenação de aperfeiçoamento de pessoal de nível superior'))">
                        <xsl:text>CAPES: </xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="
                        functx:contains-any-of(lower-case(ancestor::node()[2]/grant_agency),(
                        'fundunesp',
                        'fundacao para o desenvolvimento da unesp',
                        'fundação para o desenvolvimento da unesp'))">
                        <xsl:text>FUNDUNESP: </xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="
                        functx:contains-any-of(lower-case(ancestor::node()[2]/grant_agency),(
                        'faperj',
                        'fundacao de amparo a pesquisa do estado do rio de janeiro',
                        'fundação de amparo à pesquisa do estado do rio de janeiro',
                        'carlos chagas filho'))">
                        <xsl:text>FAPERJ: </xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="
                        functx:contains-any-of(lower-case(ancestor::node()[2]/grant_agency),(
                        'fapemig',
                        'fundacao de amparo a pesquisa do estado de minas gerais',
                        'fundação de amparo à pesquisa do estado de minas gerais'))">
                        <xsl:text>FAPEMIG: </xsl:text>
                    </xsl:when>
                    
                    <xsl:otherwise>
                        <xsl:value-of select="ancestor::node()[2]/grant_agency" />
                    	<xsl:text>: </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:choose>
                	<xsl:when test="starts-with(lower-case(.),'proc. ')">
                		<xsl:value-of select="substring-after(.,'Proc. ')"/>
                		<xsl:value-of select="substring-after(.,'proc. ')"/>
                	</xsl:when>
                	<xsl:otherwise>
                		<xsl:value-of select="."/>
                	</xsl:otherwise>
                </xsl:choose>
            	
            </dcvalue>
        </xsl:for-each>
     
        <!-- dc.identifier -->
        
        <xsl:if test="dynamic_data/cluster_related/identifiers/identifier[@type='doi' or @type='xref_doi']">
            <dcvalue element="identifier">
                <xsl:text>http://dx.doi.org/</xsl:text>
                <xsl:choose>
                    <xsl:when test="dynamic_data/cluster_related/identifiers/identifier[@type='doi']">
                        <xsl:value-of select="dynamic_data/cluster_related/identifiers/identifier[@type='doi'][1]/@value" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="dynamic_data/cluster_related/identifiers/identifier[@type='xref_doi'][1]/@value" />
                    </xsl:otherwise>
                </xsl:choose>
            </dcvalue>
        </xsl:if>
     
        <!-- dc.identifier.doi -->
        
        <xsl:if test="dynamic_data/cluster_related/identifiers/identifier[@type='doi' or @type='xref_doi']">
            <dcvalue element="identifier" qualifier="doi">
                <xsl:choose>
                    <xsl:when test="dynamic_data/cluster_related/identifiers/identifier[@type='doi']">
                        <xsl:value-of select="dynamic_data/cluster_related/identifiers/identifier[@type='doi'][1]/@value" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="dynamic_data/cluster_related/identifiers/identifier[@type='xref_doi'][1]/@value" />
                    </xsl:otherwise>
                </xsl:choose>
            </dcvalue>
        </xsl:if>
     
        <!-- dc.identifier.issn -->
        
        <xsl:for-each select="dynamic_data/cluster_related/identifiers/identifier[@type='issn']">
            <dcvalue element="identifier" qualifier="issn">
                <xsl:value-of select="./@value" />
            </dcvalue>
        </xsl:for-each>
     
        <!-- dc.identifier.wos -->
        
        <dcvalue element="identifier" qualifier="wos" >
            <xsl:value-of select="UID"/>
        </dcvalue>
     
        <!-- dc.language.iso -->
        
        <dcvalue element="language" qualifier="iso" >
            <xsl:choose>
                <xsl:when test="static_data/fullrecord_metadata/languages/language[@type='primary']='English'">eng</xsl:when>
                <xsl:when test="static_data/fullrecord_metadata/languages/language[@type='primary']='Portuguese'">por</xsl:when>
                <xsl:when test="static_data/fullrecord_metadata/languages/language[@type='primary']='Spanish'">spa</xsl:when>
                <xsl:when test="static_data/fullrecord_metadata/languages/language[@type='primary']='German'">deu</xsl:when>
                <xsl:when test="static_data/fullrecord_metadata/languages/language[@type='primary']='French'">fra</xsl:when>
                <xsl:when test="static_data/fullrecord_metadata/languages/language[@type='primary']='Italian'">ita</xsl:when>
                <xsl:when test="static_data/fullrecord_metadata/languages/language[@type='primary']='Chinese'">zho</xsl:when>
	            <xsl:otherwise>
	            	<xsl:value-of select="static_data/fullrecord_metadata/languages/language[@type='primary']"></xsl:value-of>
	            </xsl:otherwise>
            </xsl:choose>
        </dcvalue>
        
        <!-- dc.publisher -->
        
        <dcvalue element="publisher">
            <xsl:choose>
                <xsl:when test="contains(lower-case(static_data/summary/publishers/publisher[1]/names/name[1]/display_name),'elsevier')">
                    <xsl:text>Elsevier B.V.</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case(static_data/summary/publishers/publisher[1]/names/name[1]/display_name),'springer')">
                    <xsl:text>Springer</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case(static_data/summary/publishers/publisher[1]/names/name[1]/display_name),'wiley')">
                    <xsl:text>Wiley-Blackwell</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="CamelCase">
                        <xsl:with-param name="text">
                            <xsl:value-of select="static_data/summary/publishers/publisher[1]/names/name[1]/display_name" />
                        </xsl:with-param>
                    </xsl:call-template>                    
                </xsl:otherwise>
            </xsl:choose>
        </dcvalue>
        
        <!-- dc.relation.isPartOf -->
        
        <dcvalue element="relation" qualifier="isPartOf" >
            <xsl:call-template name="CamelCase">
                <xsl:with-param name="text">
                    <xsl:value-of select="static_data/summary/titles/title[@type='source'][1]"/>
                </xsl:with-param>
            </xsl:call-template>
        </dcvalue>
     
        <!-- dc.rights.license -->
        
        <dcvalue element="rights" qualifier="license">
            <xsl:choose>
                <xsl:when test="contains(lower-case(static_data/summary/publishers/publisher[1]/names/name[1]/display_name),'elsevier')">
                    <xsl:text>http://www.elsevier.com/about/open-access/open-access-policies/article-posting-policy</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case(static_data/summary/publishers/publisher[1]/names/name[1]/display_name),'springer')">
                    <xsl:text>http://www.springer.com/open+access/authors+rights?SGWID=0-176704-12-683201-0</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case(static_data/summary/publishers/publisher[1]/names/name[1]/display_name),'wiley')">
                    <xsl:text>http://olabout.wiley.com/WileyCDA/Section/id-406071.html</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case(static_data/summary/publishers/publisher[1]/names/name[1]/display_name),'amer physical soc')">
                    <xsl:text>http://publish.aps.org/authors/transfer-of-copyright-agreement</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case(static_data/summary/publishers/publisher[1]/names/name[1]/display_name),'taylor')">
                    <xsl:text>http://journalauthors.tandf.co.uk/permissions/reusingOwnWork.asp</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case(static_data/summary/publishers/publisher[1]/names/name[1]/display_name),'iop publishing')">
                    <xsl:text>http://iopscience.iop.org/page/copyright</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case(static_data/summary/publishers/publisher[1]/names/name[1]/display_name),'ieee')">
                    <xsl:text>http://www.ieee.org/publications_standards/publications/rights/rights_policies.html</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case(static_data/summary/publishers/publisher[1]/names/name[1]/display_name),'i e e e')">
                    <xsl:text>http://www.ieee.org/publications_standards/publications/rights/rights_policies.html</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case(static_data/summary/publishers/publisher[1]/names/name[1]/display_name),'cambridge')">
                    <xsl:text>http://journals.cambridge.org/action/displaySpecialPage?pageId=4676</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case(static_data/summary/publishers/publisher[1]/names/name[1]/display_name),'sage publications')">
                    <xsl:text>http://www.uk.sagepub.com/aboutus/openaccess.htm</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case(static_data/summary/publishers/publisher[1]/names/name[1]/display_name),'oxford')">
                    <xsl:text>http://www.oxfordjournals.org/access_purchase/self-archiving_policyb.html</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case(static_data/summary/publishers/publisher[1]/names/name[1]/display_name),'informa healthcare')">
                    <xsl:text>http://informahealthcare.com/userimages/ContentEditor/1255620309227/Copyright_And_Permissions.pdf</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case(static_data/summary/publishers/publisher[1]/names/name[1]/display_name),'ios press')">
                    <xsl:text>http://www.iospress.nl/service/authors/author-copyright-agreement/</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case(static_data/summary/publishers/publisher[1]/names/name[1]/display_name),'karger')">
                    <xsl:text>http://www.karger.com/Services/RightsPermissions</xsl:text>
                </xsl:when>
            </xsl:choose>
        </dcvalue>
        
        <!-- dc.rights.rightsHolder -->
        
        <dcvalue element="rights" qualifier="rightsHolder">
            <xsl:choose>
                <xsl:when test="contains(lower-case(static_data/summary/publishers/publisher[1]/names/name[1]/display_name),'elsevier')">
                    <xsl:text>Elsevier B.V.</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case(static_data/summary/publishers/publisher[1]/names/name[1]/display_name),'springer')">
                    <xsl:text>Springer</xsl:text>
                </xsl:when>
                <xsl:when test="contains(lower-case(static_data/summary/publishers/publisher[1]/names/name[1]/display_name),'wiley')">
                    <xsl:text>Wiley-Blackwell</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="CamelCase">
                        <xsl:with-param name="text">
                            <xsl:value-of select="static_data/summary/publishers/publisher[1]/names/name[1]/display_name" />
                        </xsl:with-param>
                    </xsl:call-template>                    
                </xsl:otherwise>
            </xsl:choose>
        </dcvalue>
        
        <!-- dc.source -->
        
        <dcvalue element="source" >
            <xsl:text>Web of Science</xsl:text>
        </dcvalue>
        
        <!-- dc.subject -->
        
        <xsl:for-each select="static_data/fullrecord_metadata/keywords/keyword">
            <dcvalue element="subject">
                <xsl:value-of select="." />
            </dcvalue>
        </xsl:for-each>
        
        <!-- dc.title -->
        
        <dcvalue element="title" language="en">
            <xsl:value-of select="static_data/summary/titles/title[@type='item'][1]" />
        </dcvalue>
        
        <!-- dc.type -->
        
        <dcvalue element="type">
            <xsl:choose>
                <xsl:when test="static_data/fullrecord_metadata/normalized_doctypes/doctype[1] = 'Abstract'">Resumo</xsl:when>
                <xsl:when test="static_data/fullrecord_metadata/normalized_doctypes/doctype[1] = 'Article'">Artigo</xsl:when>
                <xsl:when test="static_data/fullrecord_metadata/normalized_doctypes/doctype[1] = 'Book'">Livro</xsl:when>
                <xsl:when test="static_data/fullrecord_metadata/normalized_doctypes/doctype[1] = 'Bibliography'">Bibliografia</xsl:when>
                <xsl:when test="static_data/fullrecord_metadata/normalized_doctypes/doctype[1] = 'Book Chapter'">Capítulo de livro</xsl:when>
                <xsl:when test="static_data/fullrecord_metadata/normalized_doctypes/doctype[1] = 'Correction'">Errata</xsl:when>
                <xsl:when test="static_data/fullrecord_metadata/normalized_doctypes/doctype[1] = 'Editorial Material'">Editorial</xsl:when>
                <xsl:when test="static_data/fullrecord_metadata/normalized_doctypes/doctype[1] = 'Letter'">Carta</xsl:when>
                <xsl:when test="static_data/fullrecord_metadata/normalized_doctypes/doctype[1] = 'Note'">Nota</xsl:when>
                <xsl:when test="static_data/fullrecord_metadata/normalized_doctypes/doctype[1] = 'Music Score'">Partitura</xsl:when>
            	<xsl:when test="static_data/fullrecord_metadata/normalized_doctypes/doctype[1] = 'Meeting'">Trabalho apresentado em evento</xsl:when>
            	<xsl:when test="contains(lower-case(static_data/fullrecord_metadata/normalized_doctypes/doctype[1]),'review')">Resenha</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="static_data/fullrecord_metadata/normalized_doctypes/doctype[1]" />
                </xsl:otherwise>
            </xsl:choose>
        </dcvalue>
               
    </xsl:template>
    
    <!-- Captaliza (coloca em maiúscula) a primeira letra de cada palavra -->
    
    <xsl:template name="CamelCase">
        <xsl:param name="text"/>
        <xsl:choose>
            <xsl:when test="contains($text,' ')">
                <xsl:call-template name="CamelCaseWord">
                    <xsl:with-param name="text" select="substring-before($text,' ')"/>
                </xsl:call-template>
                <xsl:text> </xsl:text>
                <xsl:call-template name="CamelCase">
                    <xsl:with-param name="text" select="substring-after($text,' ')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="CamelCaseWord">
                    <xsl:with-param name="text" select="$text"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="CamelCaseWord">
        <xsl:param name="text"/>
        <xsl:value-of select="translate(substring($text,1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')" /><xsl:value-of select="translate(substring($text,2,string-length($text)-1),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" />
    </xsl:template>
    
    <!-- Fim da folha de estilo =) -->
    
    <!--    Fabrício Silva Assumpção
            Repositório Unesp
            Coordenadoria Geral de Bibliotecas (CGB)
            assumpcao.f@gmail.com
            http://fabricioassumpcao.com                -->
    
</xsl:stylesheet>

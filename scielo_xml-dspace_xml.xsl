<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:functx="http://www.functx.com"
    exclude-result-prefixes="#all" version="2.0">
    
    <!-- Folha de estilo XSLT 2.0 utilizada para a conversão dos registros XML da SciELO em registros Dublin Core (XML padrão do DSpace) -->
	
    <!--  Última atualização: 2021-06-29
		==================================
        Repositório Insitucional UNESP
        
        Elaborada pela Equipe do Repositório Institucional UNESP
        Contato: repositoriounesp@reitoria.unesp.br
        ================================== 
        
        Em 2021-06-29 foi iniciada a atualização para o novo formato dos registros da Scielo, de 2021
     -->
    
    <xsl:output method="xml" indent="yes" version="1.0" encoding="UTF-8" omit-xml-declaration="no"/>
    
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
    
    <xsl:function name="functx:replace-multi" as="xs:string?" 
        xmlns:functx="http://www.functx.com" >
        <xsl:param name="arg" as="xs:string?"/> 
        <xsl:param name="changeFrom" as="xs:string*"/> 
        <xsl:param name="changeTo" as="xs:string*"/> 
        <xsl:sequence select=" 
            if (count($changeFrom) > 0)
            then functx:replace-multi(
            replace($arg, $changeFrom[1],
            functx:if-absent($changeTo[1],'')),
            $changeFrom[position() > 1],
            $changeTo[position() > 1])
            else $arg
            "/>
    </xsl:function>
    
    <xsl:function name="functx:if-absent" as="item()*" 
        xmlns:functx="http://www.functx.com" >
        <xsl:param name="arg" as="item()*"/> 
        <xsl:param name="value" as="item()*"/> 
        <xsl:sequence select=" 
            if (exists($arg))
            then $arg
            else $value
            "/>
    </xsl:function>
   
	<xsl:function name="functx:capitalize-first" as="xs:string?"
		xmlns:functx="http://www.functx.com">
		<xsl:param name="arg" as="xs:string?"/>
		
		<xsl:sequence select="
			concat(upper-case(substring($arg,1,1)),
			substring($arg,2))
			"/>
		
	</xsl:function>
   
    <xsl:function name="functx:trim" as="xs:string"
        xmlns:functx="http://www.functx.com">
        <xsl:param name="arg" as="xs:string?"/>
        
        <xsl:sequence select="
            replace(replace($arg,'\s+$',''),'^\s+','')
            "/>
        
    </xsl:function>
    
	<!-- Início da folha de estilo -->
    
    <!-- Para cada elemento "article/front" do arquivo XML de entrada é chamado o template "record" -->
    
    <xsl:template match="/">
        <records>
        	<xsl:for-each select="articles/article/front">
                <xsl:call-template name="record" />
            </xsl:for-each>
        </records>
    </xsl:template>
    
    <!-- Template record. Cada "record" resultará em um registro Dublin Core do documento XML de saída -->
    
    <xsl:template name="record">
        <dublin_core schema="dc"> 
        
            <!-- Variáveis utilizadas mais de uma vez na composição do registro Dublin Core do documento XML de saída -->
            
            <xsl:variable name="dc.description.extent">
                <xsl:value-of select="article-meta/fpage" />
                <xsl:text>-</xsl:text>
                <xsl:value-of select="article-meta/lpage" />
            </xsl:variable>
            
            <xsl:variable name="dc.publisher">
                <xsl:value-of select="journal-meta/publisher[1]/publisher-name" />
            </xsl:variable>
            
            <xsl:variable name="dc.relation.ispartof">
                <xsl:value-of select="journal-meta/journal-title-group/journal-title" />
            </xsl:variable>
            
            <!-- Metadados (campos) do registro Dublin Core -->
            
            <!-- dc.contributor.author -->
            
            <xsl:for-each select="article-meta/contrib-group/contrib">
                <dcvalue element="contributor" qualifier="author">
                   <xsl:call-template name="CamelCase">
                       <xsl:with-param name="text">
                           <xsl:value-of select="name/surname"/>
                           <xsl:text>, </xsl:text>
                           <xsl:value-of select="name/given-names"/>
                       </xsl:with-param>
                   </xsl:call-template>
                    
                    <xsl:variable name="rid" select="xref[@ref-type='aff']/@rid" />
                                  
                    <xsl:variable name="aff">
                        <xsl:value-of select="../..//aff[@id=$rid]/institution[@content-type='orgname']"/>
                    </xsl:variable>
                    
                    <!-- Procura na afiliação do autor se há alguma menção à UNESP. Se há algum menção, é adiciona " [UNESP]" após o nome do autor -->
                    
                    <xsl:if test="
                        functx:contains-any-of(lower-case($aff),
                        ('unesp',
                        'univ estadual paulista',
                        'universidade estadual paulista',
                        'paulista state univ',
                        'sao paulo state univ',
                        'são paulo state univ',
                        'state univ sao paulo',
                        'state univ são paulo',
                        'univ estad paulista',
                        'estadual paulista‏',
                        'universidade estadual de são paulo',
                        'mesquita filho'))">
                        <xsl:text> [UNESP]</xsl:text>
                    </xsl:if>
                    
                </dcvalue>
            </xsl:for-each>

            <!-- dc.author.orcid -->
            
            <xsl:for-each select="article-meta/contrib-group/contrib">
                <xsl:if test="contrib-id[@contrib-id-type='orcid']">
                    <dcvalue element="author" qualifier="orcid">
                        <xsl:value-of select="contrib-id"/>
                        <xsl:text>[</xsl:text>
                        <xsl:call-template name="CamelCase">
                            <xsl:with-param name="text">
                                <xsl:value-of select="name/given-names"/>
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="name/surname"/>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:text>]</xsl:text>
                    </dcvalue>
                </xsl:if>
            </xsl:for-each>     
            <!-- dc.contributor.institution -->
            
            <xsl:for-each select="article-meta//aff/institution[@content-type='orgname']">
                <dcvalue element="contributor" qualifier="institution">
                    <xsl:choose>
                        
                        <!-- Padroniza os nomes das principais instituições -->
                        
                        <xsl:when test="
                            functx:contains-any-of(lower-case(.),
                            ('unesp',
                            'univ estadual paulista',
                            'universidade estadual paulista',
                            'paulista state univ',
                            'sao paulo state univ',
                            'são paulo state univ',
                            'state univ sao paulo',
                            'state univ são paulo',
                            'univ estad paulista',
                            'estadual paulista‏',
                            'mesquita filho'))">
                            <xsl:text>Universidade Estadual Paulista (UNESP)</xsl:text>
                        </xsl:when>
                        
                        <xsl:when test="
                            functx:contains-any-of(lower-case(.),
                            ('unicamp',
                            'univ campinas',
                            'univ estadual campinas',
                            'universidade estadual de campinas',
                            'universidade de campinas',
                            'campinas univ',
                            'campinas state univ',
                            'university of campinas',
                            'campinas estadual univ'))">
                            <xsl:text>Universidade Estadual de Campinas (UNICAMP)</xsl:text>
                        </xsl:when>
                        
                        <xsl:when test="
                            functx:contains-any-of(lower-case(.),
                            ('univ de sao paulo',
                            'univ de são paulo',
                            'universidade de são paulo',
                            'universidade de sao paulo',
                            'usp',
                            'university of sao paulo',
                            'univ sao paulo',
                            'sao paulo university'))">
                            <xsl:text>Universidade de São Paulo (USP)</xsl:text>
                        </xsl:when>
                        
                        <!-- Se a instituição não é UNESP, UNICAMP ou USP, é pego o nome como consta no registro.
                            Posteriormente, em outras conversões, decidiu-se também por padronizar os nomes de outras universidades, por exemplo, as federais -->
                        
                        <xsl:when test="starts-with(.,',')">
                            <xsl:value-of select="substring-after(.,',')" />
                        </xsl:when>
                        
                        <xsl:otherwise>
                            <xsl:value-of select="." />
                        </xsl:otherwise>
                        
                    </xsl:choose>
                </dcvalue>
            </xsl:for-each>
            
            <!-- dc.date.issued -->
            
            <dcvalue element="date" qualifier="issued">
                <xsl:value-of select="article-meta/pub-date[1]/year" />
                <xsl:if test="article-meta/pub-date[1]/month != '00'">
                	<xsl:text>-</xsl:text>
                	<xsl:value-of select="article-meta/pub-date[1]/month" />
                </xsl:if>
            	<xsl:choose>
            		<xsl:when test="article-meta/pub-date[1]/day != '00' and article-meta/pub-date[1]/month != '00'">
            			<xsl:text>-</xsl:text>
            			<xsl:value-of select="article-meta/pub-date[1]/day" />
            		</xsl:when>
            		<xsl:when test="article-meta/pub-date[1]/day = '00' and article-meta/pub-date[1]/month != '00'">
            			<xsl:text>-01</xsl:text>
            		</xsl:when>
            	</xsl:choose>
            </dcvalue>
            
            <!-- dc.description.abstract -->
            
            <xsl:for-each select="article-meta/abstract">
                <xsl:element name="dcvalue">
                    <xsl:attribute name="element">description</xsl:attribute>
                    <xsl:attribute name="qualifier">abstract</xsl:attribute>
                    <xsl:attribute name="language">
                        <!-- Aqui voltamos até article -->
                        <xsl:value-of select="../../../@xml:lang"/>
                    </xsl:attribute>
                    <xsl:call-template name="removeHtml">
                        <xsl:with-param name="string">
                            <xsl:value-of select="functx:trim(string-join(./p,' '))" />
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:element>
            </xsl:for-each>


            <!-- dc.description.abstract (translated)-->
            
            <xsl:for-each select="article-meta/trans-abstract">
                <xsl:element name="dcvalue">
                    <xsl:attribute name="element">description</xsl:attribute>
                    <xsl:attribute name="qualifier">abstract</xsl:attribute>
                    <xsl:attribute name="language">
                        <!-- Aqui está dentro da própria tag -->
                        <xsl:value-of select="./@xml:lang"/>
                    </xsl:attribute>
                    <xsl:call-template name="removeHtml">
                        <xsl:with-param name="string">
                            <xsl:value-of select="functx:trim(string-join(./p,' '))" />
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:element>
            </xsl:for-each>
            
            <!-- dc.description.affiliation -->
            
            <xsl:for-each select="article-meta//aff/institution[@content-type='orgname']">
                <dcvalue element="description" qualifier="affiliation">
                    <xsl:choose>
                        <xsl:when test="starts-with(.,',')">
                            <xsl:value-of select="substring-after(.,',')" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="." />
                        </xsl:otherwise>
                    </xsl:choose>
                    
                    <!-- Coloca a subdivisão, se houver -->
                    <xsl:if test="../institution[@content-type='orgdiv1'] != ''">
                        <xsl:text>, </xsl:text>
                        <xsl:value-of select="../institution[@content-type='orgdiv1']" />
                    </xsl:if>
                    
                </dcvalue>
            </xsl:for-each>
            
            <!-- dc.description.affiliationUnesp -->
            
            <xsl:for-each select="article-meta//aff/institution[@content-type='orgname']">
                <xsl:if test="
                    functx:contains-any-of(lower-case(.),
                    ('unesp',
                    'univ estadual paulista',
                    'universidade estadual paulista',
                    'paulista state univ',
                    'sao paulo state univ',
                    'são paulo state univ',
                    'state univ sao paulo',
                    'state univ são paulo',
                    'univ estad paulista',
                    'estadual paulista‏',
                    'mesquita filho'))">
                    <dcvalue element="description" qualifier="affiliationUnesp">
                        <xsl:choose>
                            <xsl:when test="starts-with(.,',')">
                                <xsl:value-of select="substring-after(.,',')" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="." />
                            </xsl:otherwise>
                        </xsl:choose>
                        
                        <!-- Coloca a subdivisão, se houver -->
                        <xsl:if test="../institution[@content-type='orgdiv1'] != ''">
                            <xsl:text>, </xsl:text>
                            <xsl:value-of select="../institution[@content-type='orgdiv1']" />
                        </xsl:if>
                        
                    </dcvalue>
                </xsl:if>
            </xsl:for-each>
            
            <!-- dc.description.extent -->
            
            <dcvalue element="description" qualifier="extent">
                <xsl:value-of select="$dc.description.extent" />    
            </dcvalue>         
            
            <!-- Agência de fomento em funding-group/award-group/funding-source -->
            <xsl:for-each select="article-meta/funding-group/award-group/funding-source"> 
               <dcvalue element="description" qualifier="sponsorship">
               <xsl:choose>
                   <xsl:when test="
                   functx:contains-any-of(lower-case(.),(
                   'fapesp',
                   'fundação de amparo à pesquisa do estado de são paulo',
                   'fundacao de amparo a pesquisa do estado de sao paulo',
                   'fundación de apoyo a la investigación del estado de são paulo',
                   'state of são paulo research foundation',
                   'foundation for research support of the state of são paulo',
                   'foundation for research support of the state of sao paulo',                   
                   'sao paulo research foundation',
                   'são paulo state research foundation',                   
                   'sao paulo state research foundation'))">
                   <xsl:text>Fundação de Amparo à Pesquisa do Estado de São Paulo (FAPESP)</xsl:text>
               </xsl:when>
            
               <xsl:when test="
                   functx:contains-any-of(lower-case(.),(
                   'cnpq',
                   'cons. nac. desenvolv. cient. tecnol.',
                   'national council for scientific and technological development',                   
                   'conselho nacional de desenvolvimento cientifico e tecnologico',
                   'conselho nacional de desenvolvimento científico e tecnológico'))">
                   <xsl:text>Conselho Nacional de Desenvolvimento Científico e Tecnológico (CNPq)</xsl:text>
               </xsl:when>
            
               <xsl:when test="
                   functx:contains-any-of(lower-case(.),(
                   'capes',
                   'coordination of improvement of higher education personnel',
                   'coordination for the improvement of higher education personnel',                   
                   'coordenacao de aperfeicoamento de pessoal de nivel superior',
                   'coordenação de aperfeiçoamento de pessoal de nível superior'))">
                   <xsl:text>Coordenação de Aperfeiçoamento de Pessoal de Nível Superior (CAPES)</xsl:text>
               </xsl:when>
            
               <xsl:when test="
                   functx:contains-any-of(lower-case(.),(
                   'fundunesp',
                   'fundacao para o desenvolvimento da unesp',
                   'fundação para o desenvolvimento da unesp'))">
                   <xsl:text>Fundação para o Desenvolvimento da UNESP (FUNDUNESP)</xsl:text>
               </xsl:when>
        	
        	   <xsl:when test="
        	       functx:contains-any-of(lower-case(.),(
        	       'fundação araucária',
        	       'fundacao araucaria',
        	       'fundação araucaria'))">
        		   <xsl:text>Fundação Araucária de Apoio ao Desenvolvimento Científico e Tecnológico do Paraná (FAADCT/PR)</xsl:text>
        	   </xsl:when>
        	
        	   <xsl:when test="
        	       functx:contains-any-of(lower-case(.),(
        	       'fapemig',
        	       'fundacao de amparo a pesquisa do estado de minas gerais',
        	       'fundação de amparo à pesquisa do estado de minas gerais'))">
                   <xsl:text>Fundação de Amparo à Pesquisa do Estado de Minas Gerais (FAPEMIG)</xsl:text>
               </xsl:when>
            
               <xsl:when test="
                   functx:contains-any-of(lower-case(.),(
                   'faperj',
                   'fundacao de amparo a pesquisa do estado do rio de janeiro',
                   'fundação de amparo à pesquisa do estado do rio de janeiro',
                   'carlos chagas filho'))">
                   <xsl:text>Fundação de Amparo à Pesquisa do Estado do Rio de Janeiro (FAPERJ)</xsl:text>
        	   </xsl:when>

               <xsl:otherwise>
                   <xsl:value-of select="normalize-space(.)" />
               </xsl:otherwise>
                   
               </xsl:choose>
               </dcvalue>  
           </xsl:for-each>
           
            <!-- dc.description.sponsorshipId -->
            
            <xsl:for-each select="article-meta/funding-group/award-group">
                    <xsl:if test="./award-id">
                    <dcvalue element="description" qualifier="sponsorshipId">        
                    <xsl:choose>
                        <xsl:when test="
                            functx:contains-any-of(lower-case(./funding-source),(
                            'fapesp',
                            'fundação de amparo à pesquisa do estado de são paulo',
                            'fundacao de amparo a pesquisa do estado de sao paulo',
                            'fundación de apoyo a la investigación del estado de são paulo',
                            'state of são paulo research foundation',
                            'foundation for research support of the state of são paulo',
                            'foundation for research support of the state of sao paulo',
                            'sao paulo research foundation',
                            'são paulo state research foundation',
                            'sao paulo state research foundation'))">
                            <xsl:text>FAPESP: </xsl:text>
                        </xsl:when>
                        
                        <xsl:when test="
                            functx:contains-any-of(lower-case(./funding-source),(
                            'cnpq',
                            'national council for scientific and technological development',
                            'conselho nacional de desenvolvimento cientifico e tecnologico',
                            'cons. nac. desenvolv. cient. tecnol.',
                            'conselho nacional de desenvolvimento científico e tecnológico'))">
                            <xsl:text>CNPq: </xsl:text>
                        </xsl:when>
                        
                        <xsl:when test="
                            functx:contains-any-of(lower-case(./funding-source),(
                            'capes',
                            'coordination of improvement of higher education personnel',
                            'coordination for the improvement of higher education personnel',
                            'coordenacao de aperfeicoamento de pessoal de nivel superior',
                            'coordenação de aperfeiçoamento de pessoal de nível superior'))">
                            <xsl:text>CAPES: </xsl:text>
                        </xsl:when>
                        
                        <xsl:when test="
                            functx:contains-any-of(lower-case(./funding-source),(
                            'fundunesp',
                            'fundacao para o desenvolvimento da unesp',
                            'fundação para o desenvolvimento da unesp'))">
                            <xsl:text>FUNDUNESP: </xsl:text>
                        </xsl:when>
                        
                        <xsl:when test="
                            functx:contains-any-of(lower-case(./funding-source),(
                            'faperj',
                            'fundacao de amparo a pesquisa do estado do rio de janeiro',
                            'fundação de amparo à pesquisa do estado do rio de janeiro',
                            'carlos chagas filho'))">
                            <xsl:text>FAPERJ: </xsl:text>
                        </xsl:when>
                        
                        <xsl:when test="
                            functx:contains-any-of(lower-case(./funding-source),(
                            'fapemig',
                            'fundacao de amparo a pesquisa do estado de minas gerais',
                            'fundação de amparo à pesquisa do estado de minas gerais'))">
                            <xsl:text>FAPEMIG: </xsl:text>
                        </xsl:when>
                        
                        <xsl:otherwise>
                            <xsl:value-of select="./funding-source" />
                            <xsl:text>: </xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                        
                        <xsl:value-of select="string-join(.//award-id,'; ')" />
                        
                    </dcvalue>
                    </xsl:if>
                    
            </xsl:for-each>
            
        	
            <!-- dc.identifier -->
            
            <dcvalue element="identifier">
                <xsl:choose>
                    <xsl:when test="article-meta/article-id[@pub-id-type='doi'][1]">
                        <xsl:text>http://dx.doi.org/</xsl:text>
                        <xsl:value-of select="article-meta/article-id[@pub-id-type='doi'][1]" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>https://scielo.br/article/</xsl:text>
                        <xsl:value-of select="article-meta/article-id[@specific-use='scielo-v2'][1]" />
                    </xsl:otherwise>
                </xsl:choose>
            </dcvalue>
            
        	<!-- dc.identifier.citation -->
        	
        	<dcvalue element="identifier" qualifier="citation">
        		
        		<xsl:value-of select="$dc.relation.ispartof" />
        		<xsl:text>. </xsl:text>
        		
        		<xsl:if test="journal-meta/publisher[1]/publisher-loc">
        			<xsl:value-of select="journal-meta/publisher[1]/publisher-loc" />
        			<xsl:text>: </xsl:text>
        		</xsl:if>
        		
        		<xsl:value-of select="$dc.publisher" />
        		<xsl:text>, </xsl:text>
        		
        		<xsl:if test="article-meta/volume">
        			<xsl:text>v. </xsl:text>
        			<xsl:value-of select="article-meta/volume" />
        			<xsl:text>, </xsl:text>
        		</xsl:if>
        		
        		<xsl:if test="article-meta/numero">
        			<xsl:text>n. </xsl:text>
        			<xsl:value-of select="article-meta/numero" />
        			<xsl:text>, </xsl:text>
        		</xsl:if>
        		
        		<xsl:if test="article-meta/issue">
        			<xsl:text>n. </xsl:text>
        			<xsl:value-of select="article-meta/issue" />
        			<xsl:text>, </xsl:text>
        		</xsl:if>
        		
        		<xsl:if test="$dc.description.extent">
        			<xsl:text>p. </xsl:text>
        			<xsl:value-of select="$dc.description.extent" />
        			<xsl:text>, </xsl:text>
        		</xsl:if>
        		
        		<xsl:if test="article-meta/pub-date">
        			<xsl:value-of select="article-meta/pub-date[1]/year" />
        			<xsl:text>.</xsl:text>
        		</xsl:if>
        		
        	</dcvalue>
        	
            <!-- dc.identifier.doi -->
            
            <dcvalue element="identifier" qualifier="doi">
                <xsl:value-of select="article-meta/article-id[@pub-id-type='doi'][1]" />
            </dcvalue>
            
            <!-- dc.identifier.issn -->
            
            <xsl:for-each select="journal-meta/issn">
                <dcvalue element="identifier" qualifier="issn">
                    <xsl:value-of select="." />
                </dcvalue>
            </xsl:for-each>
            
            <!-- dc.identifier.scielo -->
          
            <dcvalue element="identifier" qualifier="scielo">
                <xsl:value-of select="article-meta/article-id[@specific-use='scielo-v2'][1]" />
            </dcvalue>
            
        	<!-- dc.identifier.file -->
        	
        	<dcvalue element="identifier" qualifier="file">
        	    <xsl:value-of select="concat(article-meta/article-id[@specific-use='scielo-v2'][1],'.pdf')" />
        	</dcvalue>
        	
            <!-- dc.language.iso -->
            
            <dcvalue element="language" qualifier="iso">
                <xsl:choose>
                    <xsl:when test="../@xml:lang='de'">deu</xsl:when>
                    <xsl:when test="../@xml:lang='en'">eng</xsl:when>
                    <xsl:when test="../@xml:lang='fr'">fra</xsl:when>
                    <xsl:when test="../@xml:lang='it'">ita</xsl:when>
                    <xsl:when test="../@xml:lang='la'">lat</xsl:when>
                    <xsl:when test="../@xml:lang='pl'">pol</xsl:when>
                    <xsl:when test="../@xml:lang='pt'">por</xsl:when>
                    <xsl:when test="../@xml:lang='es'">spa</xsl:when>
                    <xsl:when test="../@xml:lang='zh'">zho</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="../@xml:lang" />
                    </xsl:otherwise>
                </xsl:choose>
            </dcvalue>
            
            <!-- dc.publisher -->
            
            <dcvalue element="publisher">
                <xsl:value-of select="$dc.publisher" />
            </dcvalue>
            
            <!-- dc.relation.ispartof -->
            
            <dcvalue element="relation" qualifier="ispartof">
                <xsl:value-of select="$dc.relation.ispartof" />
            </dcvalue>
            
            <!-- dc.rights.accessRights -->
            
            <dcvalue element="rights" qualifier="accessRights">
                <xsl:text>Acesso aberto</xsl:text>
            </dcvalue>
            
            <!-- dc.source -->
            
            <dcvalue element="source">
                <xsl:text>SciELO</xsl:text>
            </dcvalue>
            
            <!-- dc.subject -->
            
            <xsl:for-each select="article-meta/kwd-group/kwd">
                <xsl:element name="dcvalue">
                    <xsl:attribute name="element">subject</xsl:attribute>
                    <xsl:attribute name="language">
                        <xsl:value-of select="../@xml:lang"/>
                    </xsl:attribute>
                    <xsl:call-template name="removeHtml">
                        <xsl:with-param name="string">
                            <xsl:value-of select="." />
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:element>
            </xsl:for-each>
            
            <!-- dc.title -->
            
            <xsl:element name="dcvalue">
                <xsl:attribute name="element">title</xsl:attribute>
                <xsl:attribute name="language">
                    <xsl:value-of select="../@xml:lang" />
                </xsl:attribute>
                <xsl:call-template name="removeHtml">
                    <xsl:with-param name="string">
                        <xsl:value-of select="article-meta/title-group/article-title[1]" />
                        <xsl:if test="article-meta/title-group/subtitle">
                            <xsl:text>: </xsl:text>
                            <xsl:value-of select="article-meta/title-group/subtitle[1]" />
                        </xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:element>
            
            <!-- dc.title.alternative -->
            
            <xsl:for-each select="article-meta/title-group/trans-title-group/trans-title">
                <xsl:element name="dcvalue">
                    <xsl:attribute name="element">title</xsl:attribute>
                    <xsl:attribute name="qualifier">alternative</xsl:attribute>
                    <xsl:attribute name="language">
                        <xsl:value-of select="../@xml:lang" />
                    </xsl:attribute>
                    <xsl:variable name="language">
                        <xsl:value-of select="../@xml:lang" />
                    </xsl:variable>
                    <xsl:call-template name="removeHtml">
                        <xsl:with-param name="string">
                            <xsl:value-of select="." />
                            <xsl:if test="ancestor::node()/subtitle[@xml:lang=$language]">
                                <xsl:text>: </xsl:text>
                                <xsl:value-of select="ancestor::node()/subtitle[@xml:lang=$language]" />
                            </xsl:if>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:element>
            </xsl:for-each>
            
            <!-- dc.type -->
        
            <dcvalue element="type">
                <xsl:text>Artigo</xsl:text>
            </dcvalue>
            
        </dublin_core>
   
    <!-- Fim do template record -->

    </xsl:template>

    <!-- Variáveis utilizadas na função replace-multi -->
    
    <xsl:variable name="replace" select="(
        '&lt;FONT FACE=Symbol&gt;',
        '&lt;/font&gt;',
        '&lt;FONT FACE=&quot;Symbol&quot;&gt;',
        '&lt;/FONT&gt;',
        '&lt;p&gt;',
        '&lt;/p&gt;',
        '&lt;b&gt;',
        '&lt;/b&gt;',
        '&lt;p align=&quot;center&quot;&gt;',
        '&lt;p align=&quot;left&quot;&gt;',
        '&amp;nbsp;',
        '&lt;font size=&quot;',
        '&quot;',
        's  ',
        '  ',
        '&#xa;'
        )"/>

    <xsl:variable name="by" select="('','','','','','','','','','','','','','','','')"/>
    
    <xsl:template name="removeHtml">
        <xsl:param name="string" />
        <xsl:value-of select="functx:replace-multi($string,$replace,$by)"/>
    </xsl:template>
    
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
        <xsl:value-of select="translate(substring($text,1,1),'abcdefghijklmnopqrstuvwxyzáàâäãéèêëíìîïóòôöõúùûüçñ','ABCDEFGHIJKLMNOPQRSTUVWXYZÁÀÂÄÃÉÈÊËÍÌÎÏÓÒÔÖÕÚÙÛÜÇÑ')" />
        <xsl:value-of select="translate(substring($text,2,string-length($text)-1),'ABCDEFGHIJKLMNOPQRSTUVWXYZÁÀÂÄÃÉÈÊËÍÌÎÏÓÒÔÖÕÚÙÛÜÇÑ','abcdefghijklmnopqrstuvwxyzáàâäãéèêëíìîïóòôöõúùûüçñ')" />
    </xsl:template>
    
</xsl:stylesheet>
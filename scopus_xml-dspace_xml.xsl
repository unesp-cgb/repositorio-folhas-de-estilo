<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xocs="http://www.elsevier.com/xml/xocs/dtd" 
    xmlns:ce="http://www.elsevier.com/xml/ani/common" 
    xmlns:ait="http://www.elsevier.com/xml/ani/ait" 
    xmlns:cto="http://www.elsevier.com/xml/cto/dtd"
    xmlns:functx="http://www.functx.com"
    xmlns:dn="http://www.elsevier.com/xml/svapi/abstract/dtd"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:output indent="yes" encoding="UTF-8" />
    
    <!-- Funções -->
    
    <xsl:function name="functx:contains-any-of" as="xs:boolean">
        <xsl:param name="arg" as="xs:string?"/> 
        <xsl:param name="searchStrings" as="xs:string*"/> 
        <xsl:sequence select="some $searchString in $searchStrings satisfies contains($arg,$searchString)"/>
    </xsl:function>
    
    <!-- Sobre ancestor::node
        
        O nó que usamos como raiz é /dn:abstracts-retrieval-response/item/bibrecord
        
        ancestor::node()[1] é /dn:abstracts-retrieval-response/item
        ancestor::node()[2] é /dn:abstracts-retrieval-response
        
        Os nomes dos ancestrais podem ser obtidos com ancestor::*/name() -->        
    
    <xsl:template match="/">
        <records>
            <!-- <xsl:text>Teste 2</xsl:text> -->
            <xsl:for-each select="/dn:abstracts-retrieval-response/item/bibrecord">
                <dublin_core schema="dc">
                   <xsl:call-template name="record" /> 
                   <!-- <xsl:text>Teste</xsl:text> -->
                </dublin_core>
            </xsl:for-each>
        </records>
    </xsl:template>
    
    <xsl:template name="record">

        <!-- dc.bibliographicCitation -->
        
        <dcvalue element="bibliographicCitation" >
            
            <xsl:value-of select="normalize-space(head/source/sourcetitle)"/>
            
            <xsl:if test="head/source/volisspag/voliss/@volume">
                <xsl:text>, v. </xsl:text>
                <xsl:value-of select="head/source/volisspag/voliss/@volume" />
            </xsl:if>
            
            <xsl:if test="head/source/volisspag/voliss/@issue">
                <xsl:text>, n. </xsl:text>
                <xsl:value-of select="head/source/volisspag/voliss/@issue" />
            </xsl:if>
            
            <xsl:if test="head/source/volisspag/pagerange">
                <xsl:text>, p. </xsl:text>
                <xsl:value-of select="head/source/volisspag/pagerange/@first" />
                <xsl:text>-</xsl:text>
                <xsl:value-of select="head/source/volisspag/pagerange/@last" />
            </xsl:if>
            
            <xsl:if test="head/source/volisspag/voliss/@issue">
                <xsl:text>, </xsl:text>
                <xsl:value-of select="head/source/publicationdate/year" />    
            </xsl:if>
            <xsl:text>.</xsl:text>
            
        </dcvalue>
        
        <!-- dc.contributor.author -->
        
        <xsl:for-each select="/dn:abstracts-retrieval-response/dn:authors/dn:author">
            <dcvalue element="contributor" qualifier="author">
                
                <xsl:variable name="auth-id" select="@auid" />

                <xsl:choose>  <!-- Por que não precisa do dn: na frente de todo mundo aqui? -->
                    <xsl:when test="/dn:abstracts-retrieval-response/item/bibrecord/head/author-group/author[@auid = $auth-id]/ce:surname and /dn:abstracts-retrieval-response/item/bibrecord/head/author-group/author[@auid = $auth-id]/ce:given-name">
                        <xsl:value-of select="normalize-space(distinct-values(/dn:abstracts-retrieval-response/item/bibrecord/head/author-group/author[@auid = $auth-id]/ce:surname))" />
                        <xsl:text>, </xsl:text>
                        <xsl:value-of select="normalize-space(distinct-values(/dn:abstracts-retrieval-response/item/bibrecord/head/author-group/author[@auid = $auth-id]/ce:given-name))" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(distinct-values(/dn:abstracts-retrieval-response/item/bibrecord/head/author-group/author[@auid = $auth-id]/preferred-name/ce:surname))" />
                        <xsl:text>, </xsl:text>
                        <xsl:value-of select="normalize-space(distinct-values(/dn:abstracts-retrieval-response/item/bibrecord/head/author-group/author[@auid = $auth-id]/preferred-name/ce:given-name))" />
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:if test="functx:contains-any-of(lower-case(string-join(/dn:abstracts-retrieval-response/item/bibrecord/head/author-group[author[@auid = $auth-id]]/affiliation/organization,' ')),
                    ('unesp',
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
        
        <xsl:for-each select="/dn:abstracts-retrieval-response/dn:authors/dn:author">
            
                <xsl:variable name="auth-id" select="@auid" />
               
                <xsl:variable name="authorsORCID">
                <xsl:if test="/dn:abstracts-retrieval-response/item/bibrecord/head/author-group/author[@auid = $auth-id and @orcid]">
                    <xsl:value-of select="/dn:abstracts-retrieval-response/item/bibrecord/head/author-group/author[@auid = $auth-id]/@orcid"/><xsl:text>[</xsl:text>
                        <xsl:choose>  <!-- Por que não precisa do dn: na frente de todo mundo aqui? -->
                          <xsl:when test="/dn:abstracts-retrieval-response/item/bibrecord/head/author-group/author[@auid = $auth-id]/ce:surname and /dn:abstracts-retrieval-response/item/bibrecord/head/author-group/author[@auid = $auth-id]/ce:given-name">
                             <xsl:value-of select="normalize-space(distinct-values(/dn:abstracts-retrieval-response/item/bibrecord/head/author-group/author[@auid = $auth-id]/ce:given-name))" />
                             <xsl:text> </xsl:text>
                             <xsl:value-of select="normalize-space(distinct-values(/dn:abstracts-retrieval-response/item/bibrecord/head/author-group/author[@auid = $auth-id]/ce:surname))" />                        
                          </xsl:when>
                          <xsl:otherwise>
                             <xsl:value-of select="normalize-space(distinct-values(/dn:abstracts-retrieval-response/item/bibrecord/head/author-group/author[@auid = $auth-id]/preferred-name/ce:given-name))" />                        
                             <xsl:text> </xsl:text>
                             <xsl:value-of select="normalize-space(distinct-values(/dn:abstracts-retrieval-response/item/bibrecord/head/author-group/author[@auid = $auth-id]/preferred-name/ce:surname))" />                        
                          </xsl:otherwise>
                        </xsl:choose>
                    <xsl:text>]</xsl:text>
                </xsl:if>
                </xsl:variable>
                
                <xsl:if test="$authorsORCID != ''">
                   <dcvalue element="author" qualifier="orcid">
                   <xsl:value-of select="$authorsORCID"/>
                   </dcvalue>
                </xsl:if>
            
        </xsl:for-each>
        
        <!-- dc.contributor.institution -->
        
        <xsl:for-each select="head/author-group/affiliation">
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
                               
                    <xsl:when test="starts-with(lower-case(./organization[last()]),'campus')">
                        <xsl:value-of select="normalize-space(./organization[last() - 1])"/>
                    </xsl:when>
                    
                    <xsl:when test="starts-with(lower-case(./organization[last()]),'depart')">
                        <xsl:value-of select="normalize-space(./organization[last() - 1])"/>
                    </xsl:when>
                    
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(./organization[last()])"/>
                    </xsl:otherwise>
                    
                </xsl:choose>
                
            </dcvalue>
        </xsl:for-each>
        
        <!-- dc.date.issued -->
        
        <dcvalue element="date" qualifier="issued">
            <xsl:value-of select="ancestor::node()[1]/ait:process-info/ait:date-sort/@year"/>
            <xsl:text>-</xsl:text>
            <xsl:choose>
                <xsl:when test="ancestor::node()[1]/ait:process-info/ait:date-sort/@month">
                    <xsl:value-of select="ancestor::node()[1]/ait:process-info/ait:date-sort/@month"/>        
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>01</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>-</xsl:text>
            <xsl:choose>
                <xsl:when test="ancestor::node()[1]/ait:process-info/ait:date-sort/@day">
                    <xsl:value-of select="ancestor::node()[1]/ait:process-info/ait:date-sort/@day"/>        
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>01</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </dcvalue>
        
        <!-- dc.description.abstract -->
        
        <xsl:for-each select="head/abstracts/abstract">
            <dcvalue element="description" qualifier="abstract">
                <xsl:attribute name="language">
                    <xsl:value-of select="./@xml:lang" />
                </xsl:attribute>
                <xsl:value-of select="normalize-space(string-join(./ce:para,' '))"/>
            </dcvalue>
        </xsl:for-each>
        
        <!-- dc.description.affiliation -->
        
        <xsl:for-each select="head/author-group/affiliation">
            <dcvalue element="description" qualifier="affiliation">
                
                <xsl:value-of select="normalize-space(string-join(./organization,' '))" />
                
                <xsl:if test="./address-part">
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="normalize-space(string-join(./address-part,' '))" />
                </xsl:if>
                
                <xsl:if test="./city-group">
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="normalize-space(string-join(./city-group,' '))" />
                </xsl:if>
                
            </dcvalue>
        </xsl:for-each>
        
        <!-- dc.description.affiliationUnesp -->
        
        <xsl:for-each select="head/author-group/affiliation">
            <xsl:if test="functx:contains-any-of(lower-case(string-join(./organization,' ')),
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
                'univ estad paulista',
                'estadual paulista‏',
                'ibilce',
                'mesquita filho'))"> 
                <dcvalue element="description" qualifier="affiliationUnesp">
                
                    <xsl:value-of select="normalize-space(string-join(./organization,' '))" />
                    
                    <xsl:if test="./address-part">
                        <xsl:text>, </xsl:text>
                        <xsl:value-of select="normalize-space(string-join(./address-part,' '))" />
                    </xsl:if>
                    
                    <xsl:if test="./city-group">
                        <xsl:text>, </xsl:text>
                        <xsl:value-of select="normalize-space(string-join(./city-group,' '))" />
                    </xsl:if>
                    
                </dcvalue>
            </xsl:if>
        </xsl:for-each>
        
        <!-- dc.description.extent -->
        
        <dcvalue element="description" qualifier="extent">
            <xsl:value-of select="head/source/volisspag/pagerange/@first" />
            <xsl:if test="head/source/volisspag/pagerange/@last">
                <xsl:text>-</xsl:text>
                <xsl:value-of select="head/source/volisspag/pagerange/@last" />
            </xsl:if>
        </dcvalue>
        
        <!-- dc.description.sponsorship -->
        
        <xsl:for-each select="head/grantlist/grant">
            <dcvalue element="description" qualifier="sponsorship">
                <xsl:choose>
                    
                    <xsl:when test="
                        functx:contains-any-of(lower-case(.),(
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
                    
                    <xsl:when test="
                        functx:contains-any-of(lower-case(.),(
                        'cnpq',
                        'conselho nacional de desenvolvimento cientifico e tecnologico',
                        'cons. nac. desenvolv. cient. tecnol.',
                        'conselho nacional de desenvolvimento científico e tecnológico'))">
                        <xsl:text>Conselho Nacional de Desenvolvimento Científico e Tecnológico (CNPq)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="
                        functx:contains-any-of(lower-case(.),(
                        'capes',
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
                        'faperj',
                        'fundacao de amparo a pesquisa do estado do rio de janeiro',
                        'fundação de amparo à pesquisa do estado do rio de janeiro',
                        'carlos chagas filho'))">
                        <xsl:text>Fundação de Amparo à Pesquisa do Estado do Rio de Janeiro (FAPERJ)</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="
                        functx:contains-any-of(lower-case(.),(
                        'fapemig',
                        'fundacao de amparo a pesquisa do estado de minas gerais',
                        'fundação de amparo à pesquisa do estado de minas gerais'))">
                        <xsl:text>Fundação de Amparo à Pesquisa do Estado de Minas Gerais (FAPEMIG)</xsl:text>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(./grant-agency)" />
                    </xsl:otherwise>
                    
                </xsl:choose>
            </dcvalue>
        </xsl:for-each>
        
        <xsl:for-each select="head/author-group/affiliation">
            
                <xsl:choose>
                    
                    <xsl:when test="
                        functx:contains-any-of(lower-case(.),(
                        'fapesp',
                        'fundação de amparo à pesquisa do estado de são paulo',
                        'fundacao de amparo a pesquisa do estado de sao paulo',
                        'fundación de apoyo a la investigación del estado de são paulo',
                        'state of são paulo research foundation',
                        'sao paulo research foundation',
                        'são paulo state research foundation',
                        'sao paulo state research foundation'))">
                        <dcvalue element="description" qualifier="sponsorship">
                            <xsl:text>Fundação de Amparo à Pesquisa do Estado de São Paulo (FAPESP)</xsl:text>
                        </dcvalue>
                    </xsl:when>
                    
                    <xsl:when test="
                        functx:contains-any-of(lower-case(.),(
                        'cnpq',
                        'conselho nacional de desenvolvimento cientifico e tecnologico',
                        'cons. nac. desenvolv. cient. tecnol.',
                        'conselho nacional de desenvolvimento científico e tecnológico'))">
                        <dcvalue element="description" qualifier="sponsorship">
                            <xsl:text>Conselho Nacional de Desenvolvimento Científico e Tecnológico (CNPq)</xsl:text>
                        </dcvalue>
                    </xsl:when>
                    
                    <xsl:when test="
                        functx:contains-any-of(lower-case(.),(
                        'capes',
                        'coordenacao de aperfeicoamento de pessoal de nivel superior',
                        'coordenação de aperfeiçoamento de pessoal de nível superior'))">
                        <dcvalue element="description" qualifier="sponsorship">
                            <xsl:text>Coordenação de Aperfeiçoamento de Pessoal de Nível Superior (CAPES)</xsl:text>
                        </dcvalue>
                    </xsl:when>
                    
                    <xsl:when test="
                        functx:contains-any-of(lower-case(.),(
                        'fundunesp',
                        'fundacao para o desenvolvimento da unesp',
                        'fundação para o desenvolvimento da unesp'))">
                        <dcvalue element="description" qualifier="sponsorship">
                            <xsl:text>Fundação para o Desenvolvimento da UNESP (FUNDUNESP)</xsl:text>
                        </dcvalue>
                    </xsl:when>
                    
                    <xsl:when test="
                        functx:contains-any-of(lower-case(.),(
                        'faperj',
                        'fundacao de amparo a pesquisa do estado do rio de janeiro',
                        'fundação de amparo à pesquisa do estado do rio de janeiro',
                        'carlos chagas filho'))">
                        <dcvalue element="description" qualifier="sponsorship">
                            <xsl:text>Fundação de Amparo à Pesquisa do Estado do Rio de Janeiro (FAPERJ)</xsl:text>
                        </dcvalue>
                    </xsl:when>
                    
                    <xsl:when test="
                        functx:contains-any-of(lower-case(.),(
                        'fapemig',
                        'fundacao de amparo a pesquisa do estado de minas gerais',
                        'fundação de amparo à pesquisa do estado de minas gerais'))">
                        <dcvalue element="description" qualifier="sponsorship">
                            <xsl:text>Fundação de Amparo à Pesquisa do Estado de Minas Gerais (FAPEMIG)</xsl:text>
                        </dcvalue>
                    </xsl:when>
                    
                </xsl:choose>
            
        </xsl:for-each>
        
        <!-- dc.description.sponsorshipId -->
        
        <xsl:for-each select="head/grantlist/grant[grant-id]">
            <dcvalue element="description" qualifier="sponsorshipId">
                
                <xsl:choose>
                    
                    <xsl:when test="
                        functx:contains-any-of(lower-case(.),(
                        'fapesp',
                        'fundação de amparo à pesquisa do estado de são paulo',
                        'fundacao de amparo a pesquisa do estado de sao paulo',
                        'fundación de apoyo a la investigación del estado de são paulo',
                        'state of são paulo research foundation',
                        'sao paulo research foundation',
                        'são paulo state research foundation',
                        'sao paulo state research foundation'))">
                        <xsl:text>FAPESP</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="
                        functx:contains-any-of(lower-case(.),(
                        'cnpq',
                        'conselho nacional de desenvolvimento cientifico e tecnologico',
                        'cons. nac. desenvolv. cient. tecnol.',
                        'conselho nacional de desenvolvimento científico e tecnológico'))">
                        <xsl:text>CNPq</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="
                        functx:contains-any-of(lower-case(.),(
                        'capes',
                        'coordenacao de aperfeicoamento de pessoal de nivel superior',
                        'coordenação de aperfeiçoamento de pessoal de nível superior'))">
                        <xsl:text>CAPES</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="
                        functx:contains-any-of(lower-case(.),(
                        'fundunesp',
                        'fundacao para o desenvolvimento da unesp',
                        'fundação para o desenvolvimento da unesp'))">
                        <xsl:text>FUNDUNESP</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="
                        functx:contains-any-of(lower-case(.),(
                        'faperj',
                        'fundacao de amparo a pesquisa do estado do rio de janeiro',
                        'fundação de amparo à pesquisa do estado do rio de janeiro',
                        'carlos chagas filho'))">
                        <xsl:text>FAPERJ</xsl:text>
                    </xsl:when>
                    
                    <xsl:when test="
                        functx:contains-any-of(lower-case(.),(
                        'fapemig',
                        'fundacao de amparo a pesquisa do estado de minas gerais',
                        'fundação de amparo à pesquisa do estado de minas gerais'))">
                        <xsl:text>FAPEMIG</xsl:text>
                    </xsl:when>
                    
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(./grant-agency)" />
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:text>: </xsl:text>
                <xsl:value-of select="normalize-space(replace(./grant-id,'Proc. ',''))" />
            </dcvalue>
        </xsl:for-each>
        
        <!-- dc.identifier -->
        
        <xsl:if test="item-info/itemidlist/ce:doi">
            <dcvalue element="identifier">
                <xsl:text>http://dx.doi.org/</xsl:text>
                <xsl:value-of select="item-info/itemidlist/ce:doi"/>
            </dcvalue>
        </xsl:if>
        
        <!-- dc.identifier.doi -->
        
        <xsl:if test="item-info/itemidlist/ce:doi">
            <dcvalue element="identifier" qualifier="doi">
                <xsl:value-of select="item-info/itemidlist/ce:doi"/>
            </dcvalue>
        </xsl:if>
        
        <!-- dc.identifier.issn -->
      
        <xsl:for-each select="head/source/issn">
            <dcvalue element="identifier" qualifier="issn">
                <xsl:value-of select="concat(substring(.,1,4),'-',substring(.,5,4))"/>
            </dcvalue>
        </xsl:for-each>
        
        <!-- dc.identifier.scopus -->
              
        <dcvalue element="identifier" qualifier="scopus" > 
            <xsl:value-of select="ancestor::node()[2]/dn:coredata/dn:eid" />
        </dcvalue>
        
        <!-- dc.language.iso -->
        
        <xsl:for-each select="head/citation-info/citation-language/@xml:lang">
            <dcvalue element="language" qualifier="iso" >
                <xsl:value-of select="."/>
            </dcvalue>
        </xsl:for-each>
        
        <!-- dc.relation.isPartOf -->
        
        <dcvalue element="relation" qualifier="isPartOf" >
            <xsl:value-of select="normalize-space(head/source/sourcetitle)"/>
        </dcvalue>
        
        <!-- dc.source -->
        
        <dcvalue element="source" >
            <xsl:text>Scopus</xsl:text>
        </dcvalue>
        
        <!-- dc.subject -->
        
        <xsl:for-each select="head/citation-info/author-keywords/author-keyword">
            <dcvalue element="subject">
                <xsl:value-of select="normalize-space(.)"/>
            </dcvalue>
        </xsl:for-each>
        
        <xsl:for-each select="head/enhancement/descriptorgroup/descriptors/descriptor/mainterm">
            <dcvalue element="subject">
                <xsl:value-of select="normalize-space(.)"/>
            </dcvalue>
        </xsl:for-each>
        
        <!-- dc.title e dc.title.alternative -->
        
        <xsl:for-each select="head/citation-title/titletext">
            <dcvalue element="title">
                <xsl:choose>
                    
                    <xsl:when test="./@original = 'y'">
                        <xsl:if test="./@xml:lang">
                            <xsl:attribute name="language" select="./@xml:lang" />
                        </xsl:if>
                        <xsl:value-of select="normalize-space(.)" />
                    </xsl:when>
                    
                    <xsl:when test="./@original = 'n'">
                        <xsl:attribute name="qualifier">alternative</xsl:attribute>
                        <xsl:if test="./@xml:lang">
                            <xsl:attribute name="language" select="./@xml:lang" />
                        </xsl:if>
                        <xsl:value-of select="normalize-space(.)" />
                    </xsl:when>
                    
                    <xsl:otherwise>
                        <xsl:if test="./@xml:lang">
                            <xsl:attribute name="language" select="./@xml:lang" />
                        </xsl:if>
                        <xsl:value-of select="normalize-space(.)" />
                    </xsl:otherwise>
                    
                </xsl:choose>
            </dcvalue>
        </xsl:for-each>
        
        <!-- dc.type -->
        
        <dcvalue element="type">
            <xsl:choose>
                <xsl:when test="head/citation-info/citation-type/@code = 'ab'">Abstract Report</xsl:when>
                <xsl:when test="head/citation-info/citation-type/@code = 'ar'">Artigo</xsl:when>
                <xsl:when test="head/citation-info/citation-type/@code = 'bk'">Livro</xsl:when>
                <xsl:when test="head/citation-info/citation-type/@code = 'bz'">Business Article</xsl:when>
                <xsl:when test="head/citation-info/citation-type/@code = 'ch'">Capítulo de livro</xsl:when>
                <xsl:when test="head/citation-info/citation-type/@code = 'cp'">Conference Paper</xsl:when>
                <xsl:when test="head/citation-info/citation-type/@code = 'cr'">Conference Review</xsl:when>
                <xsl:when test="head/citation-info/citation-type/@code = 'ed'">Editorial</xsl:when>
                <xsl:when test="head/citation-info/citation-type/@code = 'er'">Errata</xsl:when>
                <xsl:when test="head/citation-info/citation-type/@code = 'ip'">Article in Press</xsl:when>
                <xsl:when test="head/citation-info/citation-type/@code = 'le'">Carta</xsl:when>
                <xsl:when test="head/citation-info/citation-type/@code = 'no'">Nota</xsl:when>
                <xsl:when test="head/citation-info/citation-type/@code = 'pr'">Press Release</xsl:when>
                <xsl:when test="head/citation-info/citation-type/@code = 're'">Resenha</xsl:when>
                <xsl:when test="head/citation-info/citation-type/@code = 'rp'">Relatório</xsl:when>
                <xsl:when test="head/citation-info/citation-type/@code = 'sh'">Short Survey</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="head/citation-info/citation-type/@code" />
                </xsl:otherwise>
            </xsl:choose>
        </dcvalue>
    
    </xsl:template>
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Oct 24, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> Fabrício</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
</xsl:stylesheet>
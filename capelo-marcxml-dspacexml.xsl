<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:functx="http://www.functx.com"
    xmlns:marc="http://www.loc.gov/MARC21/slim"
    xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"
    exclude-result-prefixes="xs"
    version="2.0">

    <!--
    Folha de estilo para a conversão dos registros MARC 21 (MARCXML) de TCCs em registros Dublin Core/XML
    Elaborada pela equipe técnica do Repositório Institucional UNESP (repositoriounesp@reitoria.unesp.br)
    Última atualização: 2015-03-19
	Última atualização: 2018-08-01 - Atualizado somente campo de Orientador
	Última atualização: 2018-08-21 - Atualizado somente undergraduatedID segundo portaria 2016
	Última atualização: 2020-12-03 - Removido o prefixo marc que o Alma não usa mais e alterado o dc:source
    -->
    
    <!-- Importa as regras da folha de estilo MARC21slimUtils.xsl (disponível para download em: http://www.loc.gov/standards/marcxml//xslt/MARC21slimUtils.xsl)
        que deve estar na mesma pasta do arquivo capelo-marcxml-dspacexml.xsl-->
    
    <xsl:import href="MARC21slimUtils.xsl"/>
    
    <xsl:output indent="yes" encoding="UTF-8" xml:space="default" />
    
    <!-- Funções não nativas da XSLT obtidas a partir de http://www.xsltfunctions.com/ -->
    
    <xsl:function name="functx:escape-for-regex" as="xs:string"
        xmlns:functx="http://www.functx.com" >
        <xsl:param name="arg" as="xs:string?"/>
        
        <xsl:sequence select="
            replace($arg,
            '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
            "/>
    </xsl:function>
    
    <xsl:function name="functx:substring-after-last" as="xs:string"
        xmlns:functx="http://www.functx.com" >
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:param name="delim" as="xs:string"/>
        
        <xsl:sequence select="
            replace ($arg,concat('^.*',functx:escape-for-regex($delim)),'')
            "/>
    </xsl:function>

    <xsl:function name="functx:substring-before-last" as="xs:string"
        xmlns:functx="http://www.functx.com" >
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:param name="delim" as="xs:string"/>
        
        <xsl:sequence select="
            if (matches($arg, functx:escape-for-regex($delim)))
            then replace($arg,
            concat('^(.*)', functx:escape-for-regex($delim),'.*'),
            '$1')
            else ''
            "/>
    </xsl:function>

    <!-- Template -->
    
    <!-- Para cada collection/record será chamado o template record -->
    
    <xsl:template match="/">
        <records>
            <xsl:for-each select="collection/record">
                <dublin_core schema="dc">
                    <xsl:call-template name="record" />
                </dublin_core>
            </xsl:for-each>
        </records>
    </xsl:template>

    <!-- Template record -->
    
    <!-- Cada template record dará origem a um registro Dublin Core -->
    
    <xsl:template name="record">
        
        <!-- dc.title - MARC 245ab -->
        
        <dcvalue element="title">
            
            <xsl:choose>
                <xsl:when test="substring(controlfield[@tag='008'],36,3)='por'"><xsl:attribute name="language">pt</xsl:attribute></xsl:when>
                <xsl:when test="substring(controlfield[@tag='008'],36,3)='eng'"><xsl:attribute name="language">en</xsl:attribute></xsl:when>
                <xsl:when test="substring(controlfield[@tag='008'],36,3)='spa'"><xsl:attribute name="language">es</xsl:attribute></xsl:when>
                <xsl:when test="substring(controlfield[@tag='008'],36,3)='fre'"><xsl:attribute name="language">fr</xsl:attribute></xsl:when>
            </xsl:choose>

            <xsl:for-each select="datafield[@tag=245]">
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                        <xsl:value-of select="subfield[@code='a']"/>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:if test="subfield[@code='b']">
                    <xsl:text>: </xsl:text>
                    <xsl:call-template name="chopPunctuation">
                        <xsl:with-param name="chopString">
                            <xsl:value-of select="subfield[@code='b']"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:if>
            </xsl:for-each>
        </dcvalue>
        
        <!-- dc.title.alternative - MARC 242ab -->
        
        <xsl:if test="datafield[@tag=242]">
            <dcvalue element="title" qualifier="alternative">
                
                <xsl:attribute name="language">
                    <xsl:choose>
                        <xsl:when test="datafield[@tag=242][1]/subfield[@code='y']='por'">pt</xsl:when>
                        <xsl:when test="datafield[@tag=242][1]/subfield[@code='y']='eng'">en</xsl:when>
                        <xsl:when test="datafield[@tag=242][1]/subfield[@code='y']='spa'">es</xsl:when>
                        <xsl:when test="datafield[@tag=242][1]/subfield[@code='y']='fre'">fr</xsl:when>
                    </xsl:choose>
                </xsl:attribute>
                
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                        <xsl:value-of select="datafield[@tag=242][1]/subfield[@code='a']"/>
                    </xsl:with-param>
                </xsl:call-template>
                
                <xsl:if test="datafield[@tag=242][1]/subfield[@code='b']">
                    <xsl:text>: </xsl:text>
                    <xsl:call-template name="chopPunctuation">
                        <xsl:with-param name="chopString">
                            <xsl:value-of select="datafield[@tag=242][1]/subfield[@code='b']"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:if>
            
            </dcvalue>
        </xsl:if>
        
        <!-- dc.contributor.author - MARC 100a -->
            
        <dcvalue element="contributor" qualifier="author">
            <xsl:for-each select="datafield[@tag=100]">
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">a</xsl:with-param>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:for-each>
            <xsl:text> [UNESP]</xsl:text>
        </dcvalue>
        
        <!-- dc.contributor.advisor - MARC 500a -->
        
        <xsl:for-each select="datafield[@tag=500]/subfield[@code='a']">
        	<xsl:if test="contains(.,'rientador')">
        		<dcvalue element="contributor" qualifier="advisor">
		        	<xsl:variable name="advisor">
		        		<xsl:choose>
		        			<xsl:when test="contains(.,'rientador: ')">
		        				<xsl:value-of select="substring-after(.,'rientador: ')"/>
		        			</xsl:when>
		        			<xsl:when test="contains(.,'rientadora: ')">
		        				<xsl:value-of select="substring-after(.,'rientadora: ')"/>
		        			</xsl:when>
		        			<xsl:when test="contains(.,'rientador : ')">
		        				<xsl:value-of select="substring-after(.,'rientador : ')"/>
		        			</xsl:when>
		        			<xsl:when test="contains(.,'rientadora : ')">
		        				<xsl:value-of select="substring-after(.,'rientadora : ')"/>
		        			</xsl:when>
		        			
		        			<xsl:when test="contains(.,'rientador:')">
		        				<xsl:value-of select="substring-after(.,'rientador:')"/>
		        			</xsl:when>
		        			<xsl:when test="contains(.,'rientadora:')">
		        				<xsl:value-of select="substring-after(.,'rientadora:')"/>
		        			</xsl:when>
		        			<xsl:when test="contains(.,'rientador :')">
		        				<xsl:value-of select="substring-after(.,'rientador :')"/>
		        			</xsl:when>
		        			<xsl:when test="contains(.,'rientadora :')">
		        				<xsl:value-of select="substring-after(.,'rientadora :')"/>
		        			</xsl:when>
							<xsl:when test="contains(.,'rientador(a):')">
		        				<xsl:value-of select="substring-after(.,'rientador(a):')"/>
		        			</xsl:when>
							<xsl:when test="contains(.,'rientador(a) :')">
		        				<xsl:value-of select="substring-after(.,'rientador(a) :')"/>
		        			</xsl:when>
		        		</xsl:choose>
		        	</xsl:variable>
	        		<xsl:choose>
	        			
	        			<!-- Inverte corretamente os casos em que o nome termina com "Júnior" -->
	        			
	        			<xsl:when test="ends-with($advisor,'Júnior')">
	        				<xsl:value-of select="functx:substring-after-last(replace($advisor,' Júnior',''),' ')"/>
	        				<xsl:text> Júnior, </xsl:text>
	        				<xsl:value-of select="functx:substring-before-last(replace($advisor,' Júnior',''),' ')"/>
	        			</xsl:when>
	        			
	        			<!-- Inverte corretamente os casos em que o nome termina com "Junior" (sem acento) -->
	        			
	        			<xsl:when test="ends-with($advisor,'Junior')">
	        				<xsl:value-of select="functx:substring-after-last(replace($advisor,' Junior',''),' ')"/>
	        				<xsl:text> Júnior, </xsl:text>
	        				<xsl:value-of select="functx:substring-before-last(replace($advisor,' Junior',''),' ')"/>
	        			</xsl:when>
	
	        			<!-- Inverte corretamente os casos em que o nome termina com "Filho" -->
	        			
	        			<xsl:when test="ends-with($advisor,'Filho')">
	        				<xsl:value-of select="functx:substring-after-last(replace($advisor,' Filho',''),' ')"/>
	        				<xsl:text> Filho, </xsl:text>
	        				<xsl:value-of select="functx:substring-before-last(replace($advisor,' Filho',''),' ')"/>
	        			</xsl:when>
	        			
	        			<!-- Inverte corretamente os casos em que o nome termina com "Neto" -->
	        			
	        			<xsl:when test="ends-with($advisor,'Neto')">
	        				<xsl:value-of select="functx:substring-after-last(replace($advisor,' Neto',''),' ')"/>
	        				<xsl:text> Neto, </xsl:text>
	        				<xsl:value-of select="functx:substring-before-last(replace($advisor,' Neto',''),' ')"/>
	        			</xsl:when>
	        			
	        			<!-- Inverte corretamente os casos em que o nome termina com "Sobrinho" -->
	        			
	        			<xsl:when test="ends-with($advisor,'Sobrinho')">
	        				<xsl:value-of select="functx:substring-after-last(replace($advisor,' Sobrinho',''),' ')"/>
	        				<xsl:text> Sobrinho, </xsl:text>
	        				<xsl:value-of select="functx:substring-before-last(replace($advisor,' Sobrinho',''),' ')"/>
	        			</xsl:when>
	        			
	        			<!-- Inverte o nome completo, deixando "Sobrenome, Nome" -->
	        			
	        			<xsl:otherwise>
	        				<xsl:value-of select="functx:substring-after-last($advisor,' ')"/>
	        				<xsl:text>, </xsl:text>
	        				<xsl:value-of select="functx:substring-before-last($advisor,' ')"/>
	        			</xsl:otherwise>
	        			
	        		</xsl:choose>
	            	<xsl:text> [UNESP]</xsl:text>
        		</dcvalue>
        	</xsl:if>
        </xsl:for-each>
        
        <!-- dc.contributor.institution -->
        
        <dcvalue element="contributor" qualifier="institution">Universidade Estadual Paulista (UNESP)</dcvalue>
        
        <!-- dc.date.issued - MARC 943a e 260c -->
        
        <dcvalue element="date" qualifier="issued">
            <xsl:choose>
                <xsl:when test="ends-with(datafield[@tag=943][1]/subfield[@code='a'][1],'/00/00')">
                    <xsl:value-of select="substring(datafield[@tag=943][1]/subfield[@code='a'][1],1,4)"/>
                </xsl:when>
                <xsl:when test="ends-with(datafield[@tag=943][1]/subfield[@code='a'][1],'/00')">
                    <xsl:value-of select="replace(substring(datafield[@tag=943][1]/subfield[@code='a'][1],1,7),'/','-')"/>
                </xsl:when>
                <xsl:when test="datafield[@tag=943][1]/subfield[@code='a'][1]">
                    <xsl:value-of select="replace(datafield[@tag=943][1]/subfield[@code='a'][1],'/','-')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="datafield[@tag=260][1]/subfield[@code='c']"/>
                </xsl:otherwise>
            </xsl:choose>
        </dcvalue>
        
        <!-- dc.publisher -->
        
        <dcvalue element="publisher">Universidade Estadual Paulista (UNESP)</dcvalue>
        
        <!-- dc.description.abstract - MARC 520 -->
              
        <xsl:for-each select="datafield[@tag='520']">
        	 
        	<dcvalue element="description" qualifier="abstract">
               	<xsl:choose>
                    
                    <xsl:when test="starts-with(subfield[@code='a'][1],'Resumo:')">
                        <xsl:attribute name="language">pt</xsl:attribute>
                        <xsl:value-of select="substring-after(subfield[@code='a'][1],'Resumo: ')" />
                    </xsl:when>
                	<xsl:when test="starts-with(subfield[@code='a'][1],'RESUMO:')">
                		<xsl:attribute name="language">pt</xsl:attribute>
                		<xsl:value-of select="substring-after(subfield[@code='a'][1],'RESUMO: ')" />
                	</xsl:when>
                	<xsl:when test="starts-with(subfield[@code='a'][1],'Resumo :')">
                		<xsl:attribute name="language">pt</xsl:attribute>
                		<xsl:value-of select="substring-after(subfield[@code='a'][1],'Resumo : ')" />
                	</xsl:when>
                    <xsl:when test="starts-with(subfield[@code='l'][1],'por')">
                        <xsl:attribute name="language">pt</xsl:attribute>
                        <xsl:value-of select="subfield[@code='a'][1]" />        
                    </xsl:when>
                    
                    <xsl:when test="starts-with(subfield[@code='a'][1],'Abstract: ')">
                        <xsl:attribute name="language">en</xsl:attribute>
                        <xsl:value-of select="substring-after(subfield[@code='a'][1],'Abstract: ')" />
                    </xsl:when>
                	<xsl:when test="starts-with(subfield[@code='a'][1],'ABSTRACT: ')">
                		<xsl:attribute name="language">en</xsl:attribute>
                		<xsl:value-of select="substring-after(subfield[@code='a'][1],'ABSTRACT: ')" />
                	</xsl:when>
                	<xsl:when test="starts-with(subfield[@code='a'][1],'Abstract:')">
                		<xsl:attribute name="language">en</xsl:attribute>
                		<xsl:value-of select="substring-after(subfield[@code='a'][1],'Abstract:')" />
                	</xsl:when>
                	<xsl:when test="starts-with(subfield[@code='a'][1],'Abstract :')">
                		<xsl:attribute name="language">en</xsl:attribute>
                		<xsl:value-of select="substring-after(subfield[@code='a'][1],'Abstract : ')" />
                	</xsl:when>
                	<xsl:when test="starts-with(subfield[@code='a'][1],'Abstracts: ')">
                		<xsl:attribute name="language">en</xsl:attribute>
                		<xsl:value-of select="substring-after(subfield[@code='a'][1],'Abstracts: ')" />
                	</xsl:when>
                    <xsl:when test="starts-with(subfield[@code='l'][1],'eng')">
                        <xsl:attribute name="language">en</xsl:attribute>
                        <xsl:value-of select="subfield[@code='a'][1]" />        
                    </xsl:when>
                    
                	<xsl:when test="starts-with(subfield[@code='a'][1],'The ')">
                		<xsl:attribute name="language">en</xsl:attribute>
                		<xsl:value-of select="subfield[@code='a'][1]" />
                	</xsl:when>
                	<xsl:when test="starts-with(subfield[@code='a'][1],'This ')">
                		<xsl:attribute name="language">en</xsl:attribute>
                		<xsl:value-of select="subfield[@code='a'][1]" />
                	</xsl:when>
                	<xsl:when test="starts-with(subfield[@code='a'][1],'With ')">
                		<xsl:attribute name="language">en</xsl:attribute>
                		<xsl:value-of select="subfield[@code='a'][1]" />
                	</xsl:when>
                	<xsl:when test="starts-with(subfield[@code='a'][1],'We ')">
                		<xsl:attribute name="language">en</xsl:attribute>
                		<xsl:value-of select="subfield[@code='a'][1]" />
                	</xsl:when>
                	
                    <xsl:when test="starts-with(subfield[@code='a'][1],'Resume: ')">
                        <xsl:attribute name="language">fr</xsl:attribute>
                        <xsl:value-of select="substring-after(subfield[@code='a'][1],'Resume: ')" />
                    </xsl:when>
                	<xsl:when test="starts-with(subfield[@code='a'][1],'Resume : ')">
                		<xsl:attribute name="language">fr</xsl:attribute>
                		<xsl:value-of select="substring-after(subfield[@code='a'][1],'Resume : ')" />
                	</xsl:when>
                	<xsl:when test="starts-with(subfield[@code='a'][1],'Resumé: ')">
                		<xsl:attribute name="language">fr</xsl:attribute>
                		<xsl:value-of select="substring-after(subfield[@code='a'][1],'Resumé: ')" />
                	</xsl:when>
                	<xsl:when test="starts-with(subfield[@code='a'][1],'Résumé: ')">
                		<xsl:attribute name="language">fr</xsl:attribute>
                		<xsl:value-of select="substring-after(subfield[@code='a'][1],'Résumé: ')" />
                	</xsl:when>
                    <xsl:when test="starts-with(subfield[@code='l'][1],'fre')">
                        <xsl:attribute name="language">fr</xsl:attribute>
                        <xsl:value-of select="subfield[@code='a'][1]" />        
                    </xsl:when>
                    
                    <xsl:when test="starts-with(subfield[@code='a'][1],'Resumen: ')">
                        <xsl:attribute name="language">es</xsl:attribute>
                        <xsl:value-of select="substring-after(subfield[@code='a'][1],'Resumen: ')" />
                    </xsl:when>
                	<xsl:when test="starts-with(subfield[@code='a'][1],'Resumén: ')">
                		<xsl:attribute name="language">es</xsl:attribute>
                		<xsl:value-of select="substring-after(subfield[@code='a'][1],'Resumén: ')" />
                	</xsl:when>
                    <xsl:when test="starts-with(subfield[@code='l'][1],'spa')">
                        <xsl:attribute name="language">es</xsl:attribute>
                        <xsl:value-of select="subfield[@code='a'][1]" />        
                    </xsl:when>
                    
                    <xsl:otherwise>
                    	<xsl:value-of select="subfield[@code='a'][1]" />
                    </xsl:otherwise>

                </xsl:choose>
            </dcvalue>
        </xsl:for-each>
            
        <!-- dc.format.extent - MARC 300abc -->
        
        <xsl:for-each select="datafield[@tag=300]">
        	<xsl:if test="not(starts-with(subfield[@code='a'],'1 CD-ROM'))">
	        	<dcvalue element="format" qualifier="extent">
	        		<xsl:call-template name="chopPunctuation">
	        			<xsl:with-param name="chopString">
	        				<xsl:value-of select="subfield[@code='a']"/>
	        			</xsl:with-param>
	        			<xsl:with-param name="punctuation">:</xsl:with-param>
	        		</xsl:call-template>
	            </dcvalue>
        	</xsl:if>
        </xsl:for-each>

        <!-- dc.language.iso - MARC 008/35-37 -->
            
        <dcvalue element="language" qualifier="iso">
            <xsl:choose>
            	<xsl:when test="substring(controlfield[@tag='008'],36,3) = 'mul'">por</xsl:when>
            	<xsl:otherwise>
            		<xsl:value-of select="substring(controlfield[@tag='008'],36,3)"/>
            	</xsl:otherwise>
            </xsl:choose>
        </dcvalue>
            
        <!-- dc.rights.accessRights -->
        
        <dcvalue element="rights" qualifier="accessRights">Acesso aberto</dcvalue>
            
        <!-- dc.subject - MARC 6XX, exceto 695, 696 e 697 -->
            
        <xsl:for-each select="datafield[starts-with(@tag,'6') 
            and not(@tag='692') 
            and not(@tag='695') 
            and not(@tag='696') 
            and not(@tag='697')]">
            <dcvalue element="subject" language="pt">
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">abcdqtvxyz</xsl:with-param>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </dcvalue>
        </xsl:for-each> 
            
        <xsl:for-each select="datafield[@tag='692']">
            <dcvalue element="subject" language="en">
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                        <xsl:call-template name="subfieldSelect">
                            <xsl:with-param name="codes">abcdqtvxyz</xsl:with-param>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </dcvalue>
        </xsl:for-each> 
         
        <!-- dc.type - MARC 695a -->
        
        <dcvalue element="type">
            <xsl:choose>
                <xsl:when test="starts-with(datafield[@tag=090][1]/subfield[@code='a'],'TCC')">Trabalho de conclusão de curso</xsl:when>
                <xsl:when test="starts-with(datafield[@tag=090][1]/subfield[@code='a'],'TA')">Trabalho acadêmico</xsl:when>
            </xsl:choose>
        </dcvalue>
            
        <!-- dc.description.sponsorship - MARC 536a -->
        
        <xsl:for-each select="datafield[@tag=536]/subfield[@code='a']">
            <dcvalue element="description" qualifier="sponsorship">
                <xsl:choose>
                    <xsl:when test="contains(.,'FAPESP')">Fundação de Amparo à Pesquisa do Estado de São Paulo (FAPESP)</xsl:when>
                    <xsl:when test="contains(.,'CAPES')">Coordenação de Aperfeiçoamento de Pessoal de Nível Superior (CAPES)</xsl:when>
                    <xsl:when test="contains(.,'CNPq')">Conselho Nacional de Desenvolvimento Científico e Tecnológico (CNPq)</xsl:when>
                    <xsl:when test="contains(.,'FUNDUNESP')">Fundação para o Desenvolvimento da UNESP (FUNDUNESP)</xsl:when>
                    <xsl:when test="contains(.,'Universidade Estadual Paulista')">Universidade Estadual Paulista (UNESP)</xsl:when>
                    <xsl:when test="contains(.,'FAPEMAT')">Fundação de Amparo à Pesquisa do Estado de Mato Grosso (FAPEMAT)</xsl:when>
                    <xsl:when test="contains(.,'FAPERJ')">Fundação de Amparo à Pesquisa do Estado do Rio de Janeiro (FAPERJ)</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="." />
                    </xsl:otherwise>
                </xsl:choose>
            </dcvalue>
        </xsl:for-each>
        
        <!-- dc.description.sponsorshipId - MARC 536c -->
        
        <xsl:for-each select="datafield[@tag=536][subfield[@code='c']]">
            <dcvalue element="description" qualifier="sponsorshipId">
                <xsl:choose>
                    <xsl:when test="contains(subfield[@code='a'],'FAPESP')">
                        <xsl:value-of select="concat('FAPESP: ',subfield[@code='c'][1])" />
                    </xsl:when>
                    <xsl:when test="contains(subfield[@code='a'],'CAPES')">
                        <xsl:value-of select="concat('CAPES: ',subfield[@code='c'][1])" />
                    </xsl:when>
                    <xsl:when test="contains(subfield[@code='a'],'CNPq')">
                        <xsl:value-of select="concat('CNPq: ',subfield[@code='c'][1])" />
                    </xsl:when>
                    <xsl:when test="contains(subfield[@code='a'],'FUNDUNESP')">
                        <xsl:value-of select="concat('FUNDUNESP: ',subfield[@code='c'][1])" />
                    </xsl:when>
                    <xsl:when test="contains(subfield[@code='a'],'Universidade Estadual Paulista')">
                        <xsl:value-of select="concat('UNESP: ',subfield[@code='c'][1])" />
                    </xsl:when>
                    <xsl:when test="contains(subfield[@code='a'],'FAPEMAT')">
                        <xsl:value-of select="concat('FAPEMAT: ',subfield[@code='c'][1])" />
                    </xsl:when>
                    <xsl:when test="contains(subfield[@code='a'],'FAPERJ')">
                        <xsl:value-of select="concat('FAPERJ: ',subfield[@code='c'][1])" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat(subfield[@code='a'],': ',subfield[@code='c'][1])" />
                    </xsl:otherwise>
                </xsl:choose>
            </dcvalue>
        </xsl:for-each>
        
        <!-- dc.identifier.aleph - MARC 001 (SYS) -->
        
        <dcvalue element="identifier" qualifier="aleph">
            <xsl:value-of select="controlfield[@tag=001]" />
        </dcvalue>
        
        <!-- dc.identifier.file - MARC 856u (nome do arquivo PDF) -->
        
        <xsl:for-each select="datafield[@tag=856]/subfield[@code='u']">
            <dcvalue element="identifier" qualifier="file">
                <xsl:value-of select="." />
				
				<!-- Removido para que saia o 856$u completo 
				<xsl:value-of select="substring-before(substring-after(.,'exlibris/bd/'),'.pdf')" /> -->
				
            </dcvalue>
        </xsl:for-each>
        
    	<!-- dc.identifier.citation -->
    	
    	<dcvalue element="identifier" qualifier="citation">
    		
    		<!-- Elementos da referência -->
    		
    		<!-- Autor -->
    		
    		<xsl:value-of select="upper-case(substring-before(datafield[@tag=100]/subfield[@code='a'],','))"/>
    		<xsl:text>,</xsl:text>
    		<xsl:call-template name="chopPunctuation">
    			<xsl:with-param name="chopString">
    				<xsl:value-of select="substring-after(datafield[@tag=100]/subfield[@code='a'],',')" />
    			</xsl:with-param>
    		</xsl:call-template>
    		
    		<!-- Título -->
    		
    		<xsl:text>. </xsl:text>
    		<xsl:for-each select="datafield[@tag=245]">
    			<xsl:call-template name="chopPunctuation">
    				<xsl:with-param name="chopString">
    					<xsl:value-of select="subfield[@code='a']"/>
    				</xsl:with-param>
    			</xsl:call-template>
    			<xsl:if test="subfield[@code='b']">
    				<xsl:text>: </xsl:text>
    				<xsl:call-template name="chopPunctuation">
    					<xsl:with-param name="chopString">
    						<xsl:value-of select="subfield[@code='b']"/>
    					</xsl:with-param>
    				</xsl:call-template>
    			</xsl:if>
    		</xsl:for-each>
    		
    		<!-- Ano do depósito -->
    		
    		<xsl:text>. </xsl:text>
    		<xsl:value-of select="datafield[@tag=260]/subfield[@code='c']" />
    		
    		<!-- Número de folhas -->
    		
    		<xsl:text>. </xsl:text>
    		<xsl:call-template name="chopPunctuation">
    			<xsl:with-param name="chopString">
    				<xsl:value-of select="datafield[@tag=300]/subfield[@code='a']" />
    			</xsl:with-param>
    		</xsl:call-template>
    		
    		<!-- Nota de dissertação ou tese -->
    		
    		<xsl:text>. </xsl:text>
    		<xsl:choose>
    			<xsl:when test="datafield[@tag=502]">
    				<xsl:value-of select="datafield[@tag=502]/subfield[@code='a']" />
    			</xsl:when>
    			<xsl:when test="starts-with(datafield[@tag=500][1]/subfield[@code='a'][1],'Trabalho')">
    				<xsl:value-of select="datafield[@tag=500][1]/subfield[@code='a'][1]" />
    			</xsl:when>
    			<xsl:when test="starts-with(datafield[@tag=500][2]/subfield[@code='a'][1],'Trabalho')">
    				<xsl:value-of select="datafield[@tag=500][2]/subfield[@code='a'][1]" />
    			</xsl:when>
    			<xsl:when test="starts-with(datafield[@tag=500][3]/subfield[@code='a'][1],'Trabalho')">
    				<xsl:value-of select="datafield[@tag=500][3]/subfield[@code='a'][1]" />
    			</xsl:when>
    			<xsl:when test="starts-with(datafield[@tag=500][4]/subfield[@code='a'][1],'Trabalho')">
    				<xsl:value-of select="datafield[@tag=500][4]/subfield[@code='a'][1]" />
    			</xsl:when>
    			<xsl:when test="starts-with(datafield[@tag=500][5]/subfield[@code='a'][1],'Trabalho')">
    				<xsl:value-of select="datafield[@tag=500][5]/subfield[@code='a'][1]" />
    			</xsl:when>
    		</xsl:choose>
    		
    		<!-- Ano da defesa -->
    		
    		<xsl:text>, </xsl:text>
    		<xsl:value-of select="datafield[@tag=260]/subfield[@code='c']" />
    		<xsl:text>.</xsl:text>
    	</dcvalue>
    	
        <!-- dc.source -->
        
        <dcvalue element="source">Alma</dcvalue>
        
        <!-- unesp.campus - MARC 944b -->
        
    	<xsl:variable name="undergraduateId">
    		<xsl:choose>
    			<xsl:when test="ends-with(datafield[@tag=944][1]/subfield[@code='b'],'.')">
    				<xsl:value-of select="substring-before(datafield[@tag=944][1]/subfield[@code='b'],'.')"/>
    			</xsl:when>
    			<xsl:otherwise>
    				<xsl:value-of select="datafield[@tag=944][1]/subfield[@code='b']"/>
    			</xsl:otherwise>
    		</xsl:choose>
    	</xsl:variable>
        
        <dcvalue element="campus">
        	<xsl:choose>
        		
        		<xsl:when test="$undergraduateId = '73944'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências Agrárias e Tecnológicas, Dracena</xsl:when>
        		<xsl:when test="$undergraduateId = '3202'">Universidade Estadual Paulista (Unesp), Faculdade de Arquitetura, Artes e Comunicação, Bauru</xsl:when>
        		<xsl:when test="$undergraduateId = '3199'">Universidade Estadual Paulista (Unesp), Faculdade de Arquitetura, Artes e Comunicação, Bauru</xsl:when>
        		<xsl:when test="$undergraduateId = '3198'">Universidade Estadual Paulista (Unesp), Faculdade de Arquitetura, Artes e Comunicação, Bauru</xsl:when>
        		<xsl:when test="$undergraduateId = '119088'">Universidade Estadual Paulista (Unesp), Faculdade de Arquitetura, Artes e Comunicação, Bauru</xsl:when>
        		<xsl:when test="$undergraduateId = '3204'">Universidade Estadual Paulista (Unesp), Faculdade de Arquitetura, Artes e Comunicação, Bauru</xsl:when>
				<xsl:when test="$undergraduateId = '1212283'">Universidade Estadual Paulista (Unesp), Faculdade de Arquitetura, Artes e Comunicação, Bauru</xsl:when>
				<xsl:when test="$undergraduateId = '1212284'">Universidade Estadual Paulista (Unesp), Faculdade de Arquitetura, Artes e Comunicação, Bauru</xsl:when>
        		<xsl:when test="$undergraduateId = '3219'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências, Bauru</xsl:when>
        		<xsl:when test="$undergraduateId = '3197'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências, Bauru</xsl:when>
        		<xsl:when test="$undergraduateId = '3201'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências, Bauru</xsl:when>
        		<xsl:when test="$undergraduateId = '3218'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências, Bauru</xsl:when>
        		<xsl:when test="$undergraduateId = '3217'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências, Bauru</xsl:when>
        		<xsl:when test="$undergraduateId = '61074'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências, Bauru</xsl:when>
        		<xsl:when test="$undergraduateId = '3205'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências, Bauru</xsl:when>
        		<xsl:when test="$undergraduateId = '60384'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências, Bauru</xsl:when>
        		<xsl:when test="$undergraduateId = '3193'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências, Bauru</xsl:when>
        		<xsl:when test="$undergraduateId = '3151'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências Agronômicas, Botucatu</xsl:when>
        		<xsl:when test="$undergraduateId = '3191'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências Agronômicas, Botucatu</xsl:when>
        		<xsl:when test="$undergraduateId = '85430'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências Agrárias e Veterinárias, Jaboticabal</xsl:when>
        		<xsl:when test="$undergraduateId = '3139'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências Agrárias e Veterinárias, Jaboticabal</xsl:when>
        		<xsl:when test="$undergraduateId = '52256'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências Agrárias e Veterinárias, Jaboticabal</xsl:when>
        		<xsl:when test="$undergraduateId = '3140'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências Agrárias e Veterinárias, Jaboticabal</xsl:when>
        		<xsl:when test="$undergraduateId = '3138'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências Agrárias e Veterinárias, Jaboticabal</xsl:when>
        		<xsl:when test="$undergraduateId = '3128'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências Farmacêuticas, Araraquara</xsl:when>
        		<xsl:when test="$undergraduateId = '3136'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências Humanas e Sociais, Franca</xsl:when>
        		<xsl:when test="$undergraduateId = '3135'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências Humanas e Sociais, Franca</xsl:when>
        		<xsl:when test="$undergraduateId = '66897'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências Humanas e Sociais, Franca</xsl:when>
        		<xsl:when test="$undergraduateId = '3137'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências Humanas e Sociais, Franca</xsl:when>
        		<xsl:when test="$undergraduateId = '3213'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências e Letras, Araraquara</xsl:when>
        		<xsl:when test="$undergraduateId = '3129'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências e Letras, Araraquara</xsl:when>
        		<xsl:when test="$undergraduateId = '3130'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências e Letras, Araraquara</xsl:when>
        		<xsl:when test="$undergraduateId = '3131'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências e Letras, Araraquara</xsl:when>
        		<xsl:when test="$undergraduateId = '3132'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências e Letras, Araraquara</xsl:when>
        		<xsl:when test="$undergraduateId = '66985'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências e Letras, Assis</xsl:when>
        		<xsl:when test="$undergraduateId = '3222'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências e Letras, Assis</xsl:when>
        		<xsl:when test="$undergraduateId = '3172'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências e Letras, Assis</xsl:when>
        		<xsl:when test="$undergraduateId = '3171'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências e Letras, Assis</xsl:when>
        		<xsl:when test="$undergraduateId = '3170'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências e Letras, Assis</xsl:when>
        		<xsl:when test="$undergraduateId = '66995'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências e Tecnologia, Presidente Prudente</xsl:when>
        		<xsl:when test="$undergraduateId = '52048'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências e Tecnologia, Presidente Prudente</xsl:when>
        		<xsl:when test="$undergraduateId = '3207'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências e Tecnologia, Presidente Prudente</xsl:when>
        		<xsl:when test="$undergraduateId = '52044'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências e Tecnologia, Presidente Prudente</xsl:when>
        		<xsl:when test="$undergraduateId = '3164'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências e Tecnologia, Presidente Prudente</xsl:when>
        		<xsl:when test="$undergraduateId = '3165'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências e Tecnologia, Presidente Prudente</xsl:when>
        		<xsl:when test="$undergraduateId = '52056'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências e Tecnologia, Presidente Prudente</xsl:when>
        		<xsl:when test="$undergraduateId = '3206'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências e Tecnologia, Presidente Prudente</xsl:when>
        		<xsl:when test="$undergraduateId = '3162'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências e Tecnologia, Presidente Prudente</xsl:when>
        		<xsl:when test="$undergraduateId = '3163'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências e Tecnologia, Presidente Prudente</xsl:when>
        		<xsl:when test="$undergraduateId = '3214'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências e Tecnologia, Presidente Prudente</xsl:when>
        		<xsl:when test="$undergraduateId = '66993'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências e Tecnologia, Presidente Prudente</xsl:when>
        		<xsl:when test="$undergraduateId = '3194'">Universidade Estadual Paulista (Unesp), Faculdade de Engenharia, Bauru</xsl:when>
        		<xsl:when test="$undergraduateId = '66747'">Universidade Estadual Paulista (Unesp), Faculdade de Engenharia, Bauru</xsl:when>
        		<xsl:when test="$undergraduateId = '19390'">Universidade Estadual Paulista (Unesp), Faculdade de Engenharia, Bauru</xsl:when>
        		<xsl:when test="$undergraduateId = '3196'">Universidade Estadual Paulista (Unesp), Faculdade de Engenharia, Bauru</xsl:when>
        		<xsl:when test="$undergraduateId = '19386'">Universidade Estadual Paulista (Unesp), Faculdade de Engenharia, Guaratinguetá</xsl:when>
        		<xsl:when test="$undergraduateId = '71415'">Universidade Estadual Paulista (Unesp), Faculdade de Engenharia, Guaratinguetá</xsl:when>
        		<xsl:when test="$undergraduateId = '3195'">Universidade Estadual Paulista (Unesp), Faculdade de Engenharia, Guaratinguetá</xsl:when>
        		<xsl:when test="$undergraduateId = '3174'">Universidade Estadual Paulista (Unesp), Faculdade de Engenharia, Guaratinguetá</xsl:when>
        		<xsl:when test="$undergraduateId = '19387'">Universidade Estadual Paulista (Unesp), Faculdade de Engenharia, Guaratinguetá</xsl:when>
        		<xsl:when test="$undergraduateId = '3212'">Universidade Estadual Paulista (Unesp), Faculdade de Engenharia, Guaratinguetá</xsl:when>
        		<xsl:when test="$undergraduateId = '71419'">Universidade Estadual Paulista (Unesp), Faculdade de Engenharia, Guaratinguetá</xsl:when>
        		<xsl:when test="$undergraduateId = '3160'">Universidade Estadual Paulista (Unesp), Faculdade de Engenharia, Ilha Solteira</xsl:when>
        		<xsl:when test="$undergraduateId = '60255'">Universidade Estadual Paulista (Unesp), Faculdade de Engenharia, Ilha Solteira</xsl:when>
        		<xsl:when test="$undergraduateId = '19388'">Universidade Estadual Paulista (Unesp), Faculdade de Engenharia, Ilha Solteira</xsl:when>
        		<xsl:when test="$undergraduateId = '3159'">Universidade Estadual Paulista (Unesp), Faculdade de Engenharia, Ilha Solteira</xsl:when>
        		<xsl:when test="$undergraduateId = '19389'">Universidade Estadual Paulista (Unesp), Faculdade de Engenharia, Ilha Solteira</xsl:when>
        		<xsl:when test="$undergraduateId = '60258'">Universidade Estadual Paulista (Unesp), Faculdade de Engenharia, Ilha Solteira</xsl:when>
        		<xsl:when test="$undergraduateId = '60290'">Universidade Estadual Paulista (Unesp), Faculdade de Engenharia, Ilha Solteira</xsl:when>
        		<xsl:when test="$undergraduateId = '67013'">Universidade Estadual Paulista (Unesp), Faculdade de Engenharia, Ilha Solteira</xsl:when>
        		<xsl:when test="$undergraduateId = '71065'">Universidade Estadual Paulista (Unesp), Faculdade de Filosofia e Ciências, Marília</xsl:when>
        		<xsl:when test="$undergraduateId = '3169'">Universidade Estadual Paulista (Unesp), Faculdade de Filosofia e Ciências, Marília</xsl:when>
        		<xsl:when test="$undergraduateId = '3167'">Universidade Estadual Paulista (Unesp), Faculdade de Filosofia e Ciências, Marília</xsl:when>
        		<xsl:when test="$undergraduateId = '3168'">Universidade Estadual Paulista (Unesp), Faculdade de Filosofia e Ciências, Marília</xsl:when>
        		<xsl:when test="$undergraduateId = '71069'">Universidade Estadual Paulista (Unesp), Faculdade de Filosofia e Ciências, Marília</xsl:when>
        		<xsl:when test="$undergraduateId = '3220'">Universidade Estadual Paulista (Unesp), Faculdade de Filosofia e Ciências, Marília</xsl:when>
        		<xsl:when test="$undergraduateId = '3166'">Universidade Estadual Paulista (Unesp), Faculdade de Filosofia e Ciências, Marília</xsl:when>
        		<xsl:when test="$undergraduateId = '71071'">Universidade Estadual Paulista (Unesp), Faculdade de Filosofia e Ciências, Marília</xsl:when>
        		<xsl:when test="$undergraduateId = '3215'">Universidade Estadual Paulista (Unesp), Faculdade de Medicina, Botucatu</xsl:when>
        		<xsl:when test="$undergraduateId = '3148'">Universidade Estadual Paulista (Unesp), Faculdade de Medicina, Botucatu</xsl:when>
        		<xsl:when test="$undergraduateId = '3221'">Universidade Estadual Paulista (Unesp), Faculdade de Medicina Veterinária, Araçatuba</xsl:when>
        		<xsl:when test="$undergraduateId = '3176'">Universidade Estadual Paulista (Unesp), Faculdade de Medicina Veterinária e Zootecnia, Botucatu</xsl:when>
        		<xsl:when test="$undergraduateId = '3177'">Universidade Estadual Paulista (Unesp), Faculdade de Medicina Veterinária e Zootecnia, Botucatu</xsl:when>
        		<xsl:when test="$undergraduateId = '3161'">Universidade Estadual Paulista (Unesp), Faculdade de Odontologia, Araçatuba</xsl:when>
        		<xsl:when test="$undergraduateId = '3127'">Universidade Estadual Paulista (Unesp), Faculdade de Odontologia, Araraquara</xsl:when>
        		<xsl:when test="$undergraduateId = '94756'">Universidade Estadual Paulista (Unesp), Instituto de Artes, São Paulo</xsl:when>
        		<xsl:when test="$undergraduateId = '3223'">Universidade Estadual Paulista (Unesp), Instituto de Artes, São Paulo</xsl:when>
        		<xsl:when test="$undergraduateId = '94725'">Universidade Estadual Paulista (Unesp), Instituto de Artes, São Paulo</xsl:when>
        		<xsl:when test="$undergraduateId = '3153'">Universidade Estadual Paulista (Unesp), Instituto de Artes, São Paulo</xsl:when>
        		<xsl:when test="$undergraduateId = '94758'">Universidade Estadual Paulista (Unesp), Instituto de Artes, São Paulo</xsl:when>
        		<xsl:when test="$undergraduateId = '3152'">Universidade Estadual Paulista (Unesp), Instituto de Artes, São Paulo</xsl:when>
        		<xsl:when test="$undergraduateId = '3149'">Universidade Estadual Paulista (Unesp), Instituto de Biociências, Botucatu</xsl:when>
        		<xsl:when test="$undergraduateId = '112432'">Universidade Estadual Paulista (Unesp), Instituto de Biociências, Botucatu</xsl:when>
        		<xsl:when test="$undergraduateId = '84844'">Universidade Estadual Paulista (Unesp), Instituto de Biociências, Botucatu</xsl:when>
        		<xsl:when test="$undergraduateId = '21244'">Universidade Estadual Paulista (Unesp), Instituto de Biociências, Botucatu</xsl:when>
        		<xsl:when test="$undergraduateId = '3154'">Universidade Estadual Paulista (Unesp), Instituto de Biociências Letras e Ciências Exatas, São José do Rio Preto</xsl:when>
        		<xsl:when test="$undergraduateId = '3190'">Universidade Estadual Paulista (Unesp), Instituto de Biociências Letras e Ciências Exatas, São José do Rio Preto</xsl:when>
        		<xsl:when test="$undergraduateId = '3156'">Universidade Estadual Paulista (Unesp), Instituto de Biociências Letras e Ciências Exatas, São José do Rio Preto</xsl:when>
        		<xsl:when test="$undergraduateId = '67098'">Universidade Estadual Paulista (Unesp), Instituto de Biociências Letras e Ciências Exatas, São José do Rio Preto</xsl:when>
        		<xsl:when test="$undergraduateId = '3158'">Universidade Estadual Paulista (Unesp), Instituto de Biociências Letras e Ciências Exatas, São José do Rio Preto</xsl:when>
        		<xsl:when test="$undergraduateId = '3179'">Universidade Estadual Paulista (Unesp), Instituto de Biociências Letras e Ciências Exatas, São José do Rio Preto</xsl:when>
        		<xsl:when test="$undergraduateId = '73449'">Universidade Estadual Paulista (Unesp), Instituto de Biociências Letras e Ciências Exatas, São José do Rio Preto</xsl:when>
        		<xsl:when test="$undergraduateId = '67143'">Universidade Estadual Paulista (Unesp), Instituto de Biociências Letras e Ciências Exatas, São José do Rio Preto</xsl:when>
        		<xsl:when test="$undergraduateId = '3142'">Universidade Estadual Paulista (Unesp), Instituto de Biociências, Rio Claro</xsl:when>
        		<xsl:when test="$undergraduateId = '3143'">Universidade Estadual Paulista (Unesp), Instituto de Biociências, Rio Claro</xsl:when>
        		<xsl:when test="$undergraduateId = '3141'">Universidade Estadual Paulista (Unesp), Instituto de Biociências, Rio Claro</xsl:when>
        		<xsl:when test="$undergraduateId = '3209'">Universidade Estadual Paulista (Unesp), Instituto de Biociências, Rio Claro</xsl:when>
        		<xsl:when test="$undergraduateId = '3173'">Universidade Estadual Paulista (Unesp), Instituto de Ciência e Tecnologia, São José dos Campos</xsl:when>
        		<xsl:when test="$undergraduateId = '3211'">Universidade Estadual Paulista (Unesp), Instituto de Geociências e Ciências Exatas, Rio Claro</xsl:when>
        		<xsl:when test="$undergraduateId = '67051'">Universidade Estadual Paulista (Unesp), Instituto de Geociências e Ciências Exatas, Rio Claro</xsl:when>
        		<xsl:when test="$undergraduateId = '3146'">Universidade Estadual Paulista (Unesp), Instituto de Geociências e Ciências Exatas, Rio Claro</xsl:when>
        		<xsl:when test="$undergraduateId = '3144'">Universidade Estadual Paulista (Unesp), Instituto de Geociências e Ciências Exatas, Rio Claro</xsl:when>
        		<xsl:when test="$undergraduateId = '3147'">Universidade Estadual Paulista (Unesp), Instituto de Geociências e Ciências Exatas, Rio Claro</xsl:when>
        		<xsl:when test="$undergraduateId = '3145'">Universidade Estadual Paulista (Unesp), Instituto de Geociências e Ciências Exatas, Rio Claro</xsl:when>
        		<xsl:when test="$undergraduateId = '3150'">Universidade Estadual Paulista (Unesp), Instituto de Química, Araraquara</xsl:when>
        		<xsl:when test="$undergraduateId = '82074'">Universidade Estadual Paulista (Unesp), Câmpus Experimental de Itapeva</xsl:when>
        		<xsl:when test="$undergraduateId = '82077'">Universidade Estadual Paulista (Unesp), Câmpus Experimental de Ourinhos</xsl:when>
        		<xsl:when test="$undergraduateId = '73524'">Universidade Estadual Paulista (Unesp), Câmpus Experimental de Registro</xsl:when>
        		<xsl:when test="$undergraduateId = '82295'">Universidade Estadual Paulista (Unesp), Câmpus Experimental de Rosana</xsl:when>
        		<xsl:when test="$undergraduateId = '66981'">Universidade Estadual Paulista (Unesp), Instituto de Biociências, São Vicente</xsl:when>
        		<xsl:when test="$undergraduateId = '73948'">Universidade Estadual Paulista (Unesp), Instituto de Ciência e Tecnologia, Sorocaba</xsl:when>
        		<xsl:when test="$undergraduateId = '73946'">Universidade Estadual Paulista (Unesp), Instituto de Ciência e Tecnologia, Sorocaba</xsl:when>
        		<xsl:when test="$undergraduateId = '73420'">Universidade Estadual Paulista (Unesp), Faculdade de Ciências e Engenharia, Tupã</xsl:when>
				<xsl:when test="$undergraduateId = '1278854'">Universidade Estadual Paulista (Unesp), Câmpus Experimental de São João da Boa Vista</xsl:when>
        		
        		<xsl:otherwise>
        			<xsl:value-of select="datafield[@tag=710][1]/subfield[@code='b']"/>
        		</xsl:otherwise>
        		
        	</xsl:choose>
        </dcvalue>
        
        <!-- unesp.undergraduate - MARC 944 -->
        
        <dcvalue element="undergraduate"> 
        	<xsl:choose>
        		<xsl:when test="$undergraduateId = '3127'">Odontologia - FOAR</xsl:when>
        		<xsl:when test="$undergraduateId = '3128'">Farmácia-Bioquímica - FCFAR</xsl:when>
        		<xsl:when test="$undergraduateId = '3129'">Ciências Econômicas - FCLAR</xsl:when>
        		<xsl:when test="$undergraduateId = '3130'">Ciências Sociais - FCLAR</xsl:when>
        		<xsl:when test="$undergraduateId = '3131'">Letras - FCLAR</xsl:when>
        		<xsl:when test="$undergraduateId = '3132'">Pedagogia - FCLAR</xsl:when>
        		<xsl:when test="$undergraduateId = '3135'">História - FCHS</xsl:when>
        		<xsl:when test="$undergraduateId = '3136'">Direito - FCHS</xsl:when>
        		<xsl:when test="$undergraduateId = '3137'">Serviço Social - FCHS</xsl:when>
        		<xsl:when test="$undergraduateId = '3138'">Zootecnia - FCAV</xsl:when>
        		<xsl:when test="$undergraduateId = '3139'">Agronomia - FCAV</xsl:when>
        		<xsl:when test="$undergraduateId = '3140'">Medicina Veterinária - FCAV</xsl:when>
        		<xsl:when test="$undergraduateId = '3141'">Educação Física - IBRC</xsl:when>
        		<xsl:when test="$undergraduateId = '3142'">Ciências Biológicas - IBRC</xsl:when>
        		<xsl:when test="$undergraduateId = '3143'">Ecologia - IBRC</xsl:when>
        		<xsl:when test="$undergraduateId = '3144'">Geografia - IGCE</xsl:when>
        		<xsl:when test="$undergraduateId = '3145'">Matemática - IGCE</xsl:when>
        		<xsl:when test="$undergraduateId = '3146'">Física - IGCE</xsl:when>
        		<xsl:when test="$undergraduateId = '3147'">Geologia - IGCE</xsl:when>
        		<xsl:when test="$undergraduateId = '3148'">Medicina - FMB</xsl:when>
        		<xsl:when test="$undergraduateId = '3149'">Ciências Biológicas - IBB</xsl:when>
        		<xsl:when test="$undergraduateId = '3150'">Química - IQ</xsl:when>
        		<xsl:when test="$undergraduateId = '3151'">Agronomia - FCA</xsl:when>
        		<xsl:when test="$undergraduateId = '3152'">Música - IA</xsl:when>
        		<xsl:when test="$undergraduateId = '3153'">Educação Artística - IA</xsl:when>
        		<xsl:when test="$undergraduateId = '3154'">Ciências Biológicas - IBILCE</xsl:when>
        		<xsl:when test="$undergraduateId = '3156'">Engenharia de Alimentos - IBILCE</xsl:when>
        		<xsl:when test="$undergraduateId = '3158'">Letras - IBILCE</xsl:when>
        		<xsl:when test="$undergraduateId = '3159'">Engenharia Elétrica - FEIS</xsl:when>
        		<xsl:when test="$undergraduateId = '3160'">Agronomia - FEIS</xsl:when>
        		<xsl:when test="$undergraduateId = '3161'">Odontologia - FOA</xsl:when>
        		<xsl:when test="$undergraduateId = '3162'">Geografia - FCT</xsl:when>
        		<xsl:when test="$undergraduateId = '3163'">Matemática - FCT</xsl:when>
        		<xsl:when test="$undergraduateId = '3164'">Engenharia Cartográfica - FCT</xsl:when>
        		<xsl:when test="$undergraduateId = '3165'">Estatística - FCT</xsl:when>
        		<xsl:when test="$undergraduateId = '3166'">Pedagogia - FFC</xsl:when>
        		<xsl:when test="$undergraduateId = '3167'">Ciências Sociais - FFC</xsl:when>
        		<xsl:when test="$undergraduateId = '3168'">Filosofia - FFC</xsl:when>
        		<xsl:when test="$undergraduateId = '3169'">Biblioteconomia - FFC</xsl:when>
        		<xsl:when test="$undergraduateId = '3170'">Psicologia - FCLAS</xsl:when>
        		<xsl:when test="$undergraduateId = '3171'">Letras - FCLAS</xsl:when>
        		<xsl:when test="$undergraduateId = '3172'">História - FCLAS</xsl:when>
        		<xsl:when test="$undergraduateId = '3173'">Odontologia - ICT</xsl:when>
        		<xsl:when test="$undergraduateId = '3174'">Engenharia Elétrica - FEG</xsl:when>
        		<xsl:when test="$undergraduateId = '3176'">Medicina Veterinária - FMVZ</xsl:when>
        		<xsl:when test="$undergraduateId = '3177'">Zootecnia - FMVZ</xsl:when>
        		<xsl:when test="$undergraduateId = '3179'">Matemática - IBILCE</xsl:when>
        		<xsl:when test="$undergraduateId = '3190'">Ciências da Computação - IBILCE</xsl:when>
        		<xsl:when test="$undergraduateId = '3191'">Engenharia Florestal - FCA</xsl:when>
        		<xsl:when test="$undergraduateId = '3193'">Sistemas de Informações - FC</xsl:when>
        		<xsl:when test="$undergraduateId = '3194'">Engenharia Civil - FEB</xsl:when>
        		<xsl:when test="$undergraduateId = '3195'">Engenharia de Produção Mecânica - FEG</xsl:when>
        		<xsl:when test="$undergraduateId = '3196'">Engenharia Mecânica - FEB</xsl:when>
        		<xsl:when test="$undergraduateId = '3197'">Ciências da Computação - FC</xsl:when>
        		<xsl:when test="$undergraduateId = '3198'">Desenho Industrial - FAAC</xsl:when>
        		<xsl:when test="$undergraduateId = '3199'">Comunicação Social - FAAC</xsl:when>
        		<xsl:when test="$undergraduateId = '3201'">Educação Física - FC</xsl:when>
        		<xsl:when test="$undergraduateId = '3202'">Arquitetura e Urbanismo - FAAC</xsl:when>
        		<xsl:when test="$undergraduateId = '3204'">Educação Artística - FAAC</xsl:when>
        		<xsl:when test="$undergraduateId = '3205'">Psicologia - FC</xsl:when>
        		<xsl:when test="$undergraduateId = '3206'">Fisioterapia - FCT</xsl:when>
        		<xsl:when test="$undergraduateId = '3207'">Educação Física - FCT</xsl:when>
        		<xsl:when test="$undergraduateId = '3209'">Pedagogia - IBRC</xsl:when>
        		<xsl:when test="$undergraduateId = '3211'">Ciências da Computação - IGCE</xsl:when>
        		<xsl:when test="$undergraduateId = '3212'">Física - FEG</xsl:when>
        		<xsl:when test="$undergraduateId = '3213'">Administração - FCLAR</xsl:when>
        		<xsl:when test="$undergraduateId = '3214'">Pedagogia - FCT</xsl:when>
        		<xsl:when test="$undergraduateId = '3215'">Enfermagem - FMB</xsl:when>
        		<xsl:when test="$undergraduateId = '3217'">Matemática - FC</xsl:when>
        		<xsl:when test="$undergraduateId = '3218'">Física - FC</xsl:when>
        		<xsl:when test="$undergraduateId = '3219'">Ciências Biológicas - FC</xsl:when>
        		<xsl:when test="$undergraduateId = '3220'">Fonoaudiologia - FFC</xsl:when>
        		<xsl:when test="$undergraduateId = '3221'">Medicina Veterinária - FMVA</xsl:when>
        		<xsl:when test="$undergraduateId = '3222'">Ciências Biológicas - FCLAS</xsl:when>
        		<xsl:when test="$undergraduateId = '3223'">Artes Plásticas - IA</xsl:when>
        		<xsl:when test="$undergraduateId = '19386'">Engenharia Civil - FEG</xsl:when>
        		<xsl:when test="$undergraduateId = '19387'">Engenharia Mecânica - FEG</xsl:when>
        		<xsl:when test="$undergraduateId = '19388'">Engenharia Civil - FEIS</xsl:when>
        		<xsl:when test="$undergraduateId = '19389'">Engenharia Mecânica - FEIS</xsl:when>
        		<xsl:when test="$undergraduateId = '19390'">Engenharia Elétrica - FEB</xsl:when>
        		<xsl:when test="$undergraduateId = '21244'">Nutrição - IBB</xsl:when>
        		<xsl:when test="$undergraduateId = '52044'">Engenharia Ambiental - FCT</xsl:when>
        		<xsl:when test="$undergraduateId = '52048'">Ciências da Computação - FCT</xsl:when>
        		<xsl:when test="$undergraduateId = '52056'">Física - FCT</xsl:when>
        		<xsl:when test="$undergraduateId = '52256'">Ciências Biológicas - FCAV</xsl:when>
        		<xsl:when test="$undergraduateId = '60255'">Ciências Biológicas - FEIS</xsl:when>
        		<xsl:when test="$undergraduateId = '60258'">Física - FEIS</xsl:when>
        		<xsl:when test="$undergraduateId = '60290'">Matemática - FEIS</xsl:when>
        		<xsl:when test="$undergraduateId = '60384'">Química - FC</xsl:when>
        		<xsl:when test="$undergraduateId = '61074'">Pedagogia - FC</xsl:when>
        		<xsl:when test="$undergraduateId = '66747'">Engenharia de Produção - FEB</xsl:when>
        		<xsl:when test="$undergraduateId = '66897'">Relações Internacionais - FCHS</xsl:when>
        		<xsl:when test="$undergraduateId = '66981'">Ciências Biológicas - São Vicente</xsl:when>
        		<xsl:when test="$undergraduateId = '66985'">Biotecnologia - FCLAS</xsl:when>
        		<xsl:when test="$undergraduateId = '66993'">Química - FCT</xsl:when>
        		<xsl:when test="$undergraduateId = '66995'">Arquitetura e Urbanismo - FCT</xsl:when>
        		<xsl:when test="$undergraduateId = '67013'">Zootecnia - FEIS</xsl:when>
        		<xsl:when test="$undergraduateId = '67051'">Engenharia Ambiental - IGCE</xsl:when>
        		<xsl:when test="$undergraduateId = '67098'">Física Biológica - IBILCE</xsl:when>
        		<xsl:when test="$undergraduateId = '67143'">Química Ambiental - IBILCE</xsl:when>
        		<xsl:when test="$undergraduateId = '71065'">Arquivologia - FFC</xsl:when>
        		<xsl:when test="$undergraduateId = '71069'">Fisioterapia - FFC</xsl:when>
        		<xsl:when test="$undergraduateId = '71071'">Relações Internacionais - FFC</xsl:when>
        		<xsl:when test="$undergraduateId = '71415'">Engenharia de Materiais - FEG</xsl:when>
        		<xsl:when test="$undergraduateId = '71419'">Matemática - FEG</xsl:when>
        		<xsl:when test="$undergraduateId = '73420'">Administração - Tupã</xsl:when>
        		<xsl:when test="$undergraduateId = '73449'">Pedagogia - IBILCE</xsl:when>
        		<xsl:when test="$undergraduateId = '73524'">Agronomia - Registro</xsl:when>
        		<xsl:when test="$undergraduateId = '73944'">Zootecnia - Dracena</xsl:when>
        		<xsl:when test="$undergraduateId = '73946'">Engenharia de Controle e Automação - Sorocaba</xsl:when>
        		<xsl:when test="$undergraduateId = '73948'">Engenharia Ambiental - Sorocaba</xsl:when>
        		<xsl:when test="$undergraduateId = '82074'">Engenharia Industrial Madeireira - Itapeva</xsl:when>
        		<xsl:when test="$undergraduateId = '82077'">Geografia - Ourinhos</xsl:when>
        		<xsl:when test="$undergraduateId = '82295'">Turismo - Rosana</xsl:when>
        		<xsl:when test="$undergraduateId = '84844'">Física Médica - IBB</xsl:when>
        		<xsl:when test="$undergraduateId = '85430'">Administração - FCAV</xsl:when>
        		<xsl:when test="$undergraduateId = '94725'">Artes Visuais - IA</xsl:when>
        		<xsl:when test="$undergraduateId = '94756'">Arte - Teatro - IA</xsl:when>
        		<xsl:when test="$undergraduateId = '94758'">Educação Musical - IA</xsl:when>
        		<xsl:when test="$undergraduateId = '112432'">Ciências Biomédicas - IBB</xsl:when>
        		<xsl:when test="$undergraduateId = '119088'">Design - FAAC</xsl:when>
				<xsl:when test="$undergraduateId = '1212283'">Artes Visuais Bacharelado - FAAC</xsl:when>
				<xsl:when test="$undergraduateId = '1212284'">Artes Visuais Licenciatura - FAAC</xsl:when>
				<xsl:when test="$undergraduateId = '1278854'">Engenharia de Telecomunicações - CESJBV</xsl:when>
        		
        		<xsl:otherwise>
        			<xsl:value-of select="datafield[@tag=944][1]/subfield[@code='b']"/>
        			<xsl:value-of select="datafield[@tag=944][1]/subfield[@code='a']"/>
        		</xsl:otherwise>
        		
        	</xsl:choose>
        	
        </dcvalue>
        
        <!-- collection - MARC 944 -->

    	<collection>
    		<xsl:choose>
    			
    			<xsl:when test="$undergraduateId = '3127'">11449/155904</xsl:when>
				<xsl:when test="$undergraduateId = '3128'">11449/116162</xsl:when>
    			<xsl:when test="$undergraduateId = '3129'">11449/116156</xsl:when>
    			<xsl:when test="$undergraduateId = '3130'">11449/116156</xsl:when>
    			<xsl:when test="$undergraduateId = '3131'">11449/116156</xsl:when>
    			<xsl:when test="$undergraduateId = '3132'">11449/116156</xsl:when>
				<xsl:when test="$undergraduateId = '3135'">11449/155906</xsl:when>
				<xsl:when test="$undergraduateId = '3136'">11449/155906</xsl:when>
				<xsl:when test="$undergraduateId = '3137'">11449/155906</xsl:when>
    			<xsl:when test="$undergraduateId = '3138'">11449/116148</xsl:when>
    			<xsl:when test="$undergraduateId = '3139'">11449/116148</xsl:when>
    			<xsl:when test="$undergraduateId = '3140'">11449/116148</xsl:when>
    			<xsl:when test="$undergraduateId = '3141'">11449/116154</xsl:when>
    			<xsl:when test="$undergraduateId = '3142'">11449/116154</xsl:when>
    			<xsl:when test="$undergraduateId = '3143'">11449/116154</xsl:when>
    			<xsl:when test="$undergraduateId = '3144'">11449/116155</xsl:when>
    			<xsl:when test="$undergraduateId = '3145'">11449/116155</xsl:when>
    			<xsl:when test="$undergraduateId = '3146'">11449/116155</xsl:when>
    			<xsl:when test="$undergraduateId = '3147'">11449/116155</xsl:when>
    			<xsl:when test="$undergraduateId = '3148'">11449/116157</xsl:when>
    			<xsl:when test="$undergraduateId = '3149'">11449/116153</xsl:when>
				<xsl:when test="$undergraduateId = '3150'">11449/132957</xsl:when>
				<xsl:when test="$undergraduateId = '3151'">11449/155907</xsl:when>
    			<xsl:when test="$undergraduateId = '3152'">11449/116152</xsl:when>
    			<xsl:when test="$undergraduateId = '3153'">11449/116152</xsl:when>
				<xsl:when test="$undergraduateId = '3154'">11449/155908</xsl:when>
				<xsl:when test="$undergraduateId = '3156'">11449/155908</xsl:when>
				<xsl:when test="$undergraduateId = '3158'">11449/155908</xsl:when>
				<xsl:when test="$undergraduateId = '3159'">11449/140155</xsl:when>
				<xsl:when test="$undergraduateId = '3160'">11449/140155</xsl:when>
				<xsl:when test="$undergraduateId = '3161'">11449/148950</xsl:when>
    			<xsl:when test="$undergraduateId = '3162'">11449/116151</xsl:when>
    			<xsl:when test="$undergraduateId = '3163'">11449/116151</xsl:when>
    			<xsl:when test="$undergraduateId = '3164'">11449/116151</xsl:when>
    			<xsl:when test="$undergraduateId = '3165'">11449/116151</xsl:when>
				<xsl:when test="$undergraduateId = '3166'">11449/155909</xsl:when>
				<xsl:when test="$undergraduateId = '3167'">11449/155909</xsl:when>
				<xsl:when test="$undergraduateId = '3168'">11449/155909</xsl:when>
				<xsl:when test="$undergraduateId = '3169'">11449/155909</xsl:when>
				<xsl:when test="$undergraduateId = '3170'">11449/155912</xsl:when>
				<xsl:when test="$undergraduateId = '3171'">11449/155912</xsl:when>
				<xsl:when test="$undergraduateId = '3172'">11449/155912</xsl:when>
    			<xsl:when test="$undergraduateId = '3173'">11449/116164</xsl:when>
    			<xsl:when test="$undergraduateId = '3174'">11449/116158</xsl:when>
    			<xsl:when test="$undergraduateId = '3176'">11449/116163</xsl:when>
    			<xsl:when test="$undergraduateId = '3177'">11449/116163</xsl:when>
				<xsl:when test="$undergraduateId = '3179'">11449/155908</xsl:when>
				<xsl:when test="$undergraduateId = '3190'">11449/155908</xsl:when>
				<xsl:when test="$undergraduateId = '3191'">11449/155907</xsl:when>
    			<xsl:when test="$undergraduateId = '3193'">11449/116165</xsl:when>
				<xsl:when test="$undergraduateId = '3194'">11449/155913</xsl:when>
    			<xsl:when test="$undergraduateId = '3195'">11449/116158</xsl:when>
				<xsl:when test="$undergraduateId = '3196'">11449/155913</xsl:when>
    			<xsl:when test="$undergraduateId = '3197'">11449/116165</xsl:when>
    			<xsl:when test="$undergraduateId = '3198'">11449/116150</xsl:when>
    			<xsl:when test="$undergraduateId = '3199'">11449/116150</xsl:when>
    			<xsl:when test="$undergraduateId = '3201'">11449/116165</xsl:when>
    			<xsl:when test="$undergraduateId = '3202'">11449/116150</xsl:when>
    			<xsl:when test="$undergraduateId = '3204'">11449/116150</xsl:when>
    			<xsl:when test="$undergraduateId = '3205'">11449/116165</xsl:when>
    			<xsl:when test="$undergraduateId = '3206'">11449/116151</xsl:when>
    			<xsl:when test="$undergraduateId = '3207'">11449/116151</xsl:when>
    			<xsl:when test="$undergraduateId = '3209'">11449/116154</xsl:when>
    			<xsl:when test="$undergraduateId = '3211'">11449/116155</xsl:when>
    			<xsl:when test="$undergraduateId = '3212'">11449/116158</xsl:when>
    			<xsl:when test="$undergraduateId = '3213'">11449/116156</xsl:when>
    			<xsl:when test="$undergraduateId = '3214'">11449/116151</xsl:when>
    			<xsl:when test="$undergraduateId = '3215'">11449/116157</xsl:when>
    			<xsl:when test="$undergraduateId = '3217'">11449/116165</xsl:when>
    			<xsl:when test="$undergraduateId = '3218'">11449/116165</xsl:when>
    			<xsl:when test="$undergraduateId = '3219'">11449/116165</xsl:when>
				<xsl:when test="$undergraduateId = '3220'">11449/155909</xsl:when>
				<xsl:when test="$undergraduateId = '3221'">11449/124152</xsl:when>
				<xsl:when test="$undergraduateId = '3222'">11449/155912</xsl:when>
    			<xsl:when test="$undergraduateId = '3223'">11449/116152</xsl:when>
    			<xsl:when test="$undergraduateId = '19386'">11449/116158</xsl:when>
    			<xsl:when test="$undergraduateId = '19387'">11449/116158</xsl:when>
				<xsl:when test="$undergraduateId = '19388'">11449/140155</xsl:when>
				<xsl:when test="$undergraduateId = '19389'">11449/140155</xsl:when>
				<xsl:when test="$undergraduateId = '19390'">11449/155913</xsl:when>
    			<xsl:when test="$undergraduateId = '21244'">11449/116153</xsl:when>
    			<xsl:when test="$undergraduateId = '52044'">11449/116151</xsl:when>
    			<xsl:when test="$undergraduateId = '52048'">11449/116151</xsl:when>
    			<xsl:when test="$undergraduateId = '52056'">11449/116151</xsl:when>
    			<xsl:when test="$undergraduateId = '52256'">11449/116148</xsl:when>
				<xsl:when test="$undergraduateId = '60255'">11449/140155</xsl:when>
				<xsl:when test="$undergraduateId = '60258'">11449/140155</xsl:when>
				<xsl:when test="$undergraduateId = '60290'">11449/140155</xsl:when>
    			<xsl:when test="$undergraduateId = '60384'">11449/116165</xsl:when>
    			<xsl:when test="$undergraduateId = '61074'">11449/116165</xsl:when>
				<xsl:when test="$undergraduateId = '66747'">11449/155913</xsl:when>
				<xsl:when test="$undergraduateId = '66897'">11449/155906</xsl:when>
				<xsl:when test="$undergraduateId = '66981'">11449/150976</xsl:when>
				<xsl:when test="$undergraduateId = '66985'">11449/155912</xsl:when>
    			<xsl:when test="$undergraduateId = '66993'">11449/116151</xsl:when>
    			<xsl:when test="$undergraduateId = '66995'">11449/116151</xsl:when>
				<xsl:when test="$undergraduateId = '67013'">11449/140155</xsl:when>
    			<xsl:when test="$undergraduateId = '67051'">11449/116155</xsl:when>
				<xsl:when test="$undergraduateId = '67098'">11449/155908</xsl:when>
				<xsl:when test="$undergraduateId = '67143'">11449/155908</xsl:when>
				<xsl:when test="$undergraduateId = '71065'">11449/155909</xsl:when>
				<xsl:when test="$undergraduateId = '71069'">11449/155909</xsl:when>
				<xsl:when test="$undergraduateId = '71071'">11449/155909</xsl:when>
    			<xsl:when test="$undergraduateId = '71415'">11449/116158</xsl:when>
    			<xsl:when test="$undergraduateId = '71419'">11449/116158</xsl:when>
				<xsl:when test="$undergraduateId = '73420'">11449/155916</xsl:when>
				<xsl:when test="$undergraduateId = '73449'">11449/155908</xsl:when>
				<xsl:when test="$undergraduateId = '73524'">11449/155918</xsl:when>
				<xsl:when test="$undergraduateId = '73944'">11449/155920</xsl:when>
				<xsl:when test="$undergraduateId = '73946'">11449/155921</xsl:when>
				<xsl:when test="$undergraduateId = '73948'">11449/155921</xsl:when>
    			<xsl:when test="$undergraduateId = '82074'">11449/116160</xsl:when>
				<xsl:when test="$undergraduateId = '82077'">11449/154800</xsl:when>
				<xsl:when test="$undergraduateId = '82295'">11449/155923</xsl:when>
    			<xsl:when test="$undergraduateId = '84844'">11449/116153</xsl:when>
    			<xsl:when test="$undergraduateId = '85430'">11449/116148</xsl:when>
    			<xsl:when test="$undergraduateId = '94725'">11449/116152</xsl:when>
    			<xsl:when test="$undergraduateId = '94756'">11449/116152</xsl:when>
    			<xsl:when test="$undergraduateId = '94758'">11449/116152</xsl:when>
    			<xsl:when test="$undergraduateId = '112432'">11449/116153</xsl:when>
    			<xsl:when test="$undergraduateId = '119088'">11449/116150</xsl:when>
				<xsl:when test="$undergraduateId = '1212283'">11449/116150</xsl:when>
				<xsl:when test="$undergraduateId = '1212284'">11449/116150</xsl:when>
				<xsl:when test="$undergraduateId = '1278854'">11449/155845</xsl:when>
    			
    			<xsl:otherwise>collection</xsl:otherwise>
    			
    		</xsl:choose>
    		
    	</collection>
        
    </xsl:template>
</xsl:stylesheet>

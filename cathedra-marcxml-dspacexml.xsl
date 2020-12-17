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
    Folha de estilo para a conversão dos registros MARC 21 (MARCXML) de dissertações e teses em registros Dublin Core/XML
    Elaborada pela equipe técnica do Repositório Institucional UNESP (repositoriounesp@reitoria.unesp.br)
    Última atualização: 2015-08-13
                        2020-12-03 - Removido o prefixo marc que o Alma não usa mais e alterado o dc:source
    -->
    
    <!-- Importa as regras da folha de estilo MARC21slimUtils.xsl (disponível para download em: http://www.loc.gov/standards/marcxml//xslt/MARC21slimUtils.xsl)
        que deve estar na mesma pasta do arquivo cathedra-marcxml-dspacexml.xsl-->
    
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
        
    	<!-- dc.title.alternative - MARC 242aby -->
    	
    	<xsl:for-each select="datafield[@tag=242]">
    		<dcvalue element="title" qualifier="alternative">
    			<xsl:choose>
    				<xsl:when test="subfield[@code='y']='por'"><xsl:attribute name="language">pt</xsl:attribute></xsl:when>
    				<xsl:when test="subfield[@code='y']='eng'"><xsl:attribute name="language">en</xsl:attribute></xsl:when>
    				<xsl:when test="subfield[@code='y']='spa'"><xsl:attribute name="language">es</xsl:attribute></xsl:when>
    				<xsl:when test="subfield[@code='y']='fre'"><xsl:attribute name="language">fr</xsl:attribute></xsl:when>
    				<xsl:when test="subfield[@code='y']='ita'"><xsl:attribute name="language">it</xsl:attribute></xsl:when>
    				<xsl:when test="subfield[@code='y']='deu'"><xsl:attribute name="language">de</xsl:attribute></xsl:when>
    				<xsl:otherwise>
    					<xsl:attribute name="language">en</xsl:attribute>
    				</xsl:otherwise>
    			</xsl:choose>			
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
    		</dcvalue>	
    	</xsl:for-each>
    	
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
                    <xsl:when test="starts-with(subfield[@code='l'][1],'eng')">
                        <xsl:attribute name="language">en</xsl:attribute>
                        <xsl:value-of select="subfield[@code='a'][1]" />        
                    </xsl:when>
                    
                    <xsl:when test="starts-with(subfield[@code='a'][1],'Resume: ')">
                        <xsl:attribute name="language">fr</xsl:attribute>
                        <xsl:value-of select="substring-after(subfield[@code='a'][1],'Resume: ')" />
                    </xsl:when>
                	<xsl:when test="starts-with(subfield[@code='a'][1],'Resumé: ')">
                		<xsl:attribute name="language">fr</xsl:attribute>
                		<xsl:value-of select="substring-after(subfield[@code='a'][1],'Resumé: ')" />
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
            <dcvalue element="format" qualifier="extent">
            <xsl:call-template name="subfieldSelect">
                <xsl:with-param name="codes">abce</xsl:with-param>
            </xsl:call-template>
            </dcvalue>
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
                <xsl:when test="contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">Dissertação de mestrado</xsl:when>
                <xsl:when test="contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">Tese de doutorado</xsl:when>
                <xsl:when test="contains(datafield[@tag=695][1]/subfield[@code='a'],'TL')">Tese de livre-docência</xsl:when>
                <xsl:when test="contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">Dissertação de mestrado</xsl:when>
                <xsl:when test="contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">Tese de doutorado</xsl:when>
                <xsl:when test="contains(datafield[@tag=695][2]/subfield[@code='a'],'TL')">Tese de livre-docência</xsl:when>
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
        
        <!-- description.affiliationUnesp - MARC 710b, 942a e 260a 
        
        <dcvalue element="description" qualifier="affiliationUnesp">
            <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                    <xsl:value-of select="datafield[@tag=710]/subfield[@code='b']" />
                </xsl:with-param>
            </xsl:call-template>
            <xsl:if test="datafield[@tag=942]">
                <xsl:text>, Programa de Pós-Graduação em </xsl:text>
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                        <xsl:value-of select="datafield[@tag=942]/subfield[@code='a']" />
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="datafield[@tag=260]">
                <xsl:text>, </xsl:text>
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                        <xsl:value-of select="datafield[@tag=260]/subfield[@code='a']" />
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </dcvalue> -->
        
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
        
        <!-- dc.identifier.capes - MARC 942b (código CAPES do programa de pós-graduação) -->
        
        <xsl:for-each select="datafield[@tag=942]/subfield[@code='b']">
            <dcvalue element="identifier" qualifier="capes">
                <xsl:choose>
                    <xsl:when test="ends-with(.,'.')">
                        <xsl:value-of select="substring-before(.,'.')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="." />
                    </xsl:otherwise>
                </xsl:choose>
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
    		<xsl:value-of select="datafield[@tag=502]/subfield[@code='a']" />
    		
    		<!-- Ano da defesa -->
    		
    		<xsl:text>, </xsl:text>
    		<xsl:value-of select="datafield[@tag=260]/subfield[@code='c']" />
    		<xsl:text>.</xsl:text>
    	</dcvalue>
    	
        <!-- dc.source -->
        
        <dcvalue element="source">Alma</dcvalue>
        
        <!-- unesp.campus - MARC 942b -->
        
        <dcvalue element="campus">
            <xsl:choose>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004021075P8')">Faculdade de Medicina Veterinária (FMVA)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004021073P5')">Faculdade de Odontologia (FOA)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004021011P0')">Faculdade de Odontologia (FOA)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004021074P1')">Faculdade de Odontologia (FOA)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030017P7')">Faculdade de Ciências e Letras (FCLAR)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030080P0')">Faculdade de Ciências e Letras (FCLAR)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030079P2')">Faculdade de Ciências e Letras (FCLAR)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030083P0')">Faculdade de Ciências e Letras (FCLAR)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030016P0')">Faculdade de Ciências e Letras (FCLAR)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030009P4')">Faculdade de Ciências e Letras (FCLAR)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030055P6')">Faculdade de Ciências Farmacêuticas (FCFAR)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030081P7')">Faculdade de Ciências Farmacêuticas (FCFAR)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030078P6')">Faculdade de Ciências Farmacêuticas (FCFAR)</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'52001016048P0')">Faculdade de Ciências Farmacêuticas (FCFAR)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030010P2')">Faculdade de Odontologia (FOAR)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030059P1')">Faculdade de Odontologia (FOAR)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030082P3')">Faculdade de Odontologia (FOAR)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030077P0')">Instituto de Química (IQ)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030072P8')">Instituto de Química (IQ)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004048023P9')">Faculdade de Ciências e Letras (FCLAS)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004048018P5')">Faculdade de Ciências e Letras (FCLAS)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004048019P1')">Faculdade de Ciências e Letras (FCLAS)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004048021P6')">Faculdade de Ciências e Letras (FCLAS)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056090P3')">Faculdade de Arquitetura, Artes e Comunicação (FAAC)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056081P4')">Faculdade de Arquitetura, Artes e Comunicação (FAAC)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056082P0')">Faculdade de Arquitetura, Artes e Comunicação (FAAC)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056088P9')">Faculdade de Arquitetura, Artes e Comunicação (FAAC)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056083P7')">Faculdade de Ciências (FC)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056091P0')">Faculdade de Ciências (FC)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056079P0')">Faculdade de Ciências (FC)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056085P0')">Faculdade de Ciências (FC)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056089P5')">Faculdade de Engenharia (FEB)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056086P6')">Faculdade de Engenharia (FEB)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056087P2')">Faculdade de Engenharia (FEB)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056080P8')">Faculdade de Engenharia (FEB)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064039P3')">Faculdade de Ciências Agronômicas (FCA)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064021P7')">Faculdade de Ciências Agronômicas (FCA)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064014P0')">Faculdade de Ciências Agronômicas (FCA)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064038P7')">Faculdade de Ciências Agronômicas (FCA)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064034P1')">Faculdade de Ciências Agronômicas (FCA)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064082P6')">Faculdade de Ciências Agronômicas (FCA)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064076P6')">Faculdade de Medicina (FMB)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064006P8')">Faculdade de Medicina (FMB)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064065P4')">Faculdade de Medicina (FMB)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064085P5')">Faculdade de Medicina (FMB)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064081P0')">Faculdade de Medicina (FMB)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064020P0')">Faculdade de Medicina (FMB)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064077P2')">Faculdade de Medicina (FMB)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064056P5')">Faculdade de Medicina (FMB)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064079P5')">Faculdade de Medicina (FMB)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064078P9')">Faculdade de Medicina (FMB)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064022P3')">Faculdade de Medicina Veterinária e Zootecnia (FMVZ)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064048P2')">Faculdade de Medicina Veterinária e Zootecnia (FMVZ)</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064086P1')">Faculdade de Medicina Veterinária e Zootecnia (FMVZ)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064080P3')">Instituto de Biociências (IBB)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064083P2')">Instituto de Biociências (IBB)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064025P2')">Instituto de Biociências (IBB)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064052P0')">Instituto de Biociências (IBB)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064026P9')">Instituto de Biociências (IBB)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064012P8')">Instituto de Biociências (IBB)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004072068P9')">Faculdade de Ciências Humanas e Sociais (FCHS)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004072013P0')">Faculdade de Ciências Humanas e Sociais (FCHS)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004072069P5')">Faculdade de Ciências Humanas e Sociais (FCHS)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004072067P2')">Faculdade de Ciências Humanas e Sociais (FCHS)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004080052P0')">Faculdade de Engenharia (FEG)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004080027P6')">Faculdade de Engenharia (FEG)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004080051P4')">Faculdade de Engenharia (FEG)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099079P1')">Faculdade de Engenharia (FEIS)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099083P9')">Faculdade de Engenharia (FEIS)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099086P8')">Faculdade de Engenharia (FEIS)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099084P5')">Faculdade de Engenharia (FEIS)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099080P0')">Faculdade de Engenharia (FEIS)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099082P2')">Faculdade de Engenharia (FEIS)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102071P2')">Faculdade de Ciências Agrárias e Veterinárias (FCAV)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102037P9')">Faculdade de Ciências Agrárias e Veterinárias (FCAV)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102029P6')">Faculdade de Ciências Agrárias e Veterinárias (FCAV)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102001P4')">Faculdade de Ciências Agrárias e Veterinárias (FCAV)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102049P7')">Faculdade de Ciências Agrárias e Veterinárias (FCAV)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102069P8')">Faculdade de Ciências Agrárias e Veterinárias (FCAV)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102030P4')">Faculdade de Ciências Agrárias e Veterinárias (FCAV)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102072P9')">Faculdade de Ciências Agrárias e Veterinárias (FCAV)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102070P6')">Faculdade de Ciências Agrárias e Veterinárias (FCAV)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102002P0')">Faculdade de Ciências Agrárias e Veterinárias (FCAV)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110043P4')">Faculdade de Filosofia e Ciências (FFC)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110042P8')">Faculdade de Filosofia e Ciências (FFC)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110040P5')">Faculdade de Filosofia e Ciências (FFC)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110041P1')">Faculdade de Filosofia e Ciências (FFC)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110045P7')">Faculdade de Filosofia e Ciências (FFC)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110044P0')">Faculdade de Filosofia e Ciências (FFC)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129043P0')">Faculdade de Ciências e Tecnologia (FCT)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129044P6')">Faculdade de Ciências e Tecnologia (FCT)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129045P2')">Faculdade de Ciências e Tecnologia (FCT)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129042P3')">Faculdade de Ciências e Tecnologia (FCT)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129047P5')">Faculdade de Ciências e Tecnologia (FCT)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129046P9')">Faculdade de Ciências e Tecnologia (FCT)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137046P4')">Instituto de Biociências (IBRC)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137005P6')">Instituto de Biociências (IBRC)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137041P2')">Instituto de Biociências (IBRC)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137003P3')">Instituto de Biociências (IBRC)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137062P0')">Instituto de Biociências (IBRC)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137066P5')">Instituto de Biociências (IBRC)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137067P1')">Instituto de Biociências (IBRC)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137064P2')">Instituto de Biociências (IBRC)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137031P7')">Instituto de Geociências e Ciências Exatas (IGCE)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137063P6')">Instituto de Geociências e Ciências Exatas (IGCE)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137036P9')">Instituto de Geociências e Ciências Exatas (IGCE)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137004P0')">Instituto de Geociências e Ciências Exatas (IGCE)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137035P2')">Instituto de Geociências e Ciências Exatas (IGCE)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137065P9')">Instituto de Geociências e Ciências Exatas (IGCE)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153068P9')">Instituto de Biociências, Letras e Ciências Exatas (IBILCE)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153072P6')">Instituto de Biociências, Letras e Ciências Exatas (IBILCE)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153073P2')">Instituto de Biociências, Letras e Ciências Exatas (IBILCE)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153070P3')">Instituto de Biociências, Letras e Ciências Exatas (IBILCE)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153069P5')">Instituto de Biociências, Letras e Ciências Exatas (IBILCE)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153023P5')">Instituto de Biociências, Letras e Ciências Exatas (IBILCE)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153015P2')">Instituto de Biociências, Letras e Ciências Exatas (IBILCE)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153071P0')">Instituto de Biociências, Letras e Ciências Exatas (IBILCE)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'31075010001P2')">Instituto de Biociências, Letras e Ciências Exatas (IBILCE)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153074P9')">Instituto de Biociências, Letras e Ciências Exatas (IBILCE)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153077P8')">Instituto de Biociências, Letras e Ciências Exatas (IBILCE)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004145081P0')">Instituto de Ciência e Tecnologia (ICT)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004145070P8')">Instituto de Ciência e Tecnologia (ICT)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004013063P4')">Instituto de Artes (IA)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004013066P3')">Instituto de Artes (IA)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33015015001P7')">Instituto de Física Teórica (IFT)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004013068P6')">Instituto de Políticas Públicas e Relações Internacionais (IPPRI)</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004170001P6')">Câmpus Experimental de Sorocaba</xsl:when>
                <xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004188001P8')">Câmpus Experimental de Tupã</xsl:when>
            	<xsl:when test="contains(datafield[@tag=710][1]/subfield[@code='b'][1],'São José dos Campos')">Instituto de Ciência e Tecnologia (ICT)</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat(datafield[@tag=942]/subfield[@code='a'],' ',
                        datafield[@tag=942]/subfield[@code='b'],' ',
                        datafield[@tag=710][1]/subfield[@code='b'][1])
                        "/>
                </xsl:otherwise>
            </xsl:choose>
        </dcvalue>
        
        <!-- unesp.graduateProgram - MARC 942a -->
        
        <dcvalue element="graduateProgram">
            <xsl:choose>
                
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004188001P8')">Agronegócio e Desenvolvimento - Tupã</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099079P1')">Agronomia - FEIS</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064039P3')">Agronomia (Agricultura) - FCA</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102071P2')">Agronomia (Ciência do Solo) - FCAV</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064021P7')">Agronomia (Energia na Agricultura) - FCA</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102037P9')">Agronomia (Entomologia Agrícola) - FCAV</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102029P6')">Agronomia (Genética e Melhoramento de Plantas) - FCAV</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064014P0')">Agronomia (Horticultura) - FCA</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064038P7')">Agronomia (Irrigação e Drenagem) - FCA</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102001P4')">Agronomia (Produção Vegetal) - FCAV</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064034P1')">Agronomia (Proteção de Plantas) - FCA</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030055P6')">Alimentos e Nutrição - FCFAR</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064076P6')">Anestesiologia - FMB</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102049P7')">Aquicultura - FCAV</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056090P3')">Arquitetura e Urbanismo - FAAC</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004013063P4')">Artes - IA</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064006P8')">Bases Gerais da Cirurgia - FMB</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004048023P9')">Biociências - FCLAS</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030081P7')">Biociências e Biotecnologia Aplicadas à Farmácia - FCFAR</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153068P9')">Biofísica Molecular - IBILCE</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153072P6')">Biologia Animal - IBILCE</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064080P3')">Biologia Geral e Aplicada - IBB</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064083P2')">Biometria - IBB</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004145081P0')">Biopatologia Bucal - ICT</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030077P0')">Biotecnologia - IQ</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064086P1')">Biotecnologia Animal - FMVZ</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004021075P8')">Ciência Animal - FMVA</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153073P2')">Ciência da Computação - IBILCE</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110043P4')">Ciência da Informação - FFC</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099083P9')">Ciência dos Materiais - FEIS</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099086P8')">Ciência e Tecnologia Animal - FEIS</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056083P7')">Ciência e Tecnologia de Materiais - FC</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064082P6')">Ciência Florestal - FCA</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004021073P5')">Ciência Odontólogica - FOA</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004170001P6')">Ciências Ambientais - Sorocaba</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137046P4')">Ciências Biológicas (Biologia Celular e Molecular) - IBRC</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137005P6')">Ciências Biológicas (Biologia Vegetal) - IBRC</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064025P2')">Ciências Biológicas (Botânica) - IBB</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064052P0')">Ciências Biológicas (Farmacologia) - IBB</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064026P9')">Ciências Biológicas (Genética) - IBB</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137041P2')">Ciências Biológicas (Microbiologia Aplicada) - IBRC</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064012P8')">Ciências Biológicas (Zoologia) - IBB</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137003P3')">Ciências Biológicas (Zoologia) - IBRC</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129043P0')">Ciências Cartográficas - FCT</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137062P0')">Ciências da Motricidade - IBRC</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030078P6')">Ciências Farmacêuticas - FCFAR</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33147019001P2')">Ciências Fisiológicas - FOA</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33001014037P4')">Ciências Fisiológicas - FOAR</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030010P2')">Ciências Odontológicas - FOAR</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030017P7')">Ciências Sociais - FCLAR</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110042P8')">Ciências Sociais - FFC</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102069P8')">Cirurgia Veterinária - FCAV</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056081P4')">Comunicação - FAAC</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137066P5')">Desenvolvimento Humano e Tecnologias - IBRC</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004013068P6')">Desenvolvimento Territorial na América Latina e Caribe - IPPRI</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056082P0')">Design - FAAC</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004072068P9')">Direito - FCHS</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056091P0')">Docência para a Educação Básica - FC</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064065P4')">Doenças Tropicais - FMB</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137067P1')">Ecologia e Biodiversidade - IBRC</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030080P0')">Economia - FCLAR</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129044P6')">Educação - FCT</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110040P5')">Educação - FFC</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137064P2')">Educação - IBRC</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030079P2')">Educação Escolar - FCLAR</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137031P7')">Educação Matemática - IGCE</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056079P0')">Educação para a Ciência - FC</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030083P0')">Educação Sexual - FCLAR</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064085P5')">Enfermagem - FMB</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064081P0')">Enfermagem (mestrado profissional) - FMB</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099084P5')">Engenharia Civil - FEIS</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056089P5')">Engenharia Civil e Ambiental - FEB</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056086P6')">Engenharia de Produção - FEB</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004080052P0')">Engenharia de Produção - FEG</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153070P3')">Engenharia e Ciência de Alimentos - IBILCE</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056087P2')">Engenharia Elétrica - FEB</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099080P0')">Engenharia Elétrica - FEIS</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056080P8')">Engenharia Mecânica - FEB</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004080027P6')">Engenharia Mecânica - FEG</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099082P2')">Engenharia Mecânica - FEIS</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33283010001P5')">Ensino de Física - FCT</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153069P5')">Estudos Linguísticos - IBILCE</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030016P0')">Estudos Literários - FCLAR</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110041P1')">Filosofia - FFC</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004080051P4')">Física - FEG</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33015015001P7')">Física - IFT</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137063P6')">Física - IGCE</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064020P0')">Fisiopatologia em Clínica Médica - FMB</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129045P2')">Fisioterapia - FCT</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110045P7')">Fonoaudiologia - FFC</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153023P5')">Genética - IBILCE</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102030P4')">Genética e Melhoramento Animal - FCAV</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137036P9')">Geociências e Meio Ambiente - IGCE</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129042P3')">Geografia - FCT</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137004P0')">Geografia - IGCE</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129047P5')">Geografia (mestrado profissional) - FCT</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137035P2')">Geologia Regional - IGCE</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064077P2')">Ginecologia, Obstetrícia e Mastologia - FMB</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004072013P0')">História - FCHS</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004048018P5')">História - FCLAS</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'23001011069P5')">Letras - FCLAR</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004048019P1')">Letras - FCLAS</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153015P2')">Letras - IBILCE</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030009P4')">Linguística e Língua Portuguesa - FCLAR</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153071P0')">Matemática - IBILCE</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129046P9')">Matematica Aplicada e Computacional - FCT</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'31075010001P2')">Matemática em Rede Nacional - IBILCE</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'31075010001P2')">Matemática em Rede Nacional - IBRC</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137065P9')">Matemática Universitária - IGCE</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102072P9')">Medicina Veterinária - FCAV</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064022P3')">Medicina Veterinária - FMVZ</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153074P9')">Microbiologia - IBILCE</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102070P6')">Microbiologia Agropecuária - FCAV</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004013066P3')">Música - IA</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'52001016048P0')">Nanotecnologia Farmacêutica - FCFAR</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004021011P0')">Odontologia - FOA</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030059P1')">Odontologia - FOAR</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004021074P1')">Odontologia Preventiva e Social - FOA</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004145070P8')">Odontologia Restauradora - ICT</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064056P5')">Patologia - FMB</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064079P5')">Pesquisa e Desenvolvimento (Biotecnologia Médica) - FMB</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004072069P5')">Planejamento e Análise de Políticas Públicas - FCHS</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004048021P6')">Psicologia - FCLAS</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056085P0')">Psicologia do Desenvolvimento e Aprendizagem - FC</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153077P8')">Química - IBILCE</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030072P8')">Química - IQ</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030082P3')">Reabilitação Oral - FOAR</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110044P0')">Relações Internacionais (UNESP - UNICAMP - PUC-SP) - FFC</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064078P9')">Saúde Coletiva - FMB</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004072067P2')">Serviço Social - FCHS</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056088P9')">Televisão Digital: Informação e Conhecimento - FAAC</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102002P0')">Zootecnia - FCAV</xsl:when>
            	<xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064048P2')">Zootecnia - FMVZ</xsl:when>
            	
                <xsl:otherwise>
                    <xsl:call-template name="chopPunctuation">
                        <xsl:with-param name="chopString">
                            <xsl:value-of select="datafield[@tag=942]/subfield[@code='a']" />
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </dcvalue>
        
        <!-- unesp.researchArea - MARC 945a -->
        
        <xsl:if test="datafield[@tag=945]/subfield[@code='a']">
            <dcvalue element="researchArea">
                <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                        <xsl:value-of select="datafield[@tag=945]/subfield[@code='a']" />
                    </xsl:with-param>
                </xsl:call-template>
            </dcvalue>
        </xsl:if>
        
        <!-- unesp.knowledgeArea - MARC 940a -->
        
        <dcvalue element="knowledgeArea">
            <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                    <xsl:value-of select="datafield[@tag=940]/subfield[@code='a']" />
                </xsl:with-param>
            </xsl:call-template>
        </dcvalue>
        
        <!-- collection - MARC 942b -->

        <collection>
            <xsl:choose>
                
                <!-- Dissertações - Ciência Animal - FMVA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004021075P8') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/63600</xsl:when>
                <!-- Teses - Ciência Animal - FMVA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004021075P8') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/76943</xsl:when>
                <!-- Dissertações - Ciência odontólogica - FOA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004021073P5') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/76945</xsl:when>
                <!-- Teses - Ciência odontólogica - FOA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004021073P5') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/76946</xsl:when>
                <!-- Dissertações - Odontologia - FOA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004021011P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/76949</xsl:when>
                <!-- Teses - Odontologia - FOA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004021011P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/76950</xsl:when>
                <!-- Dissertações - Odontologia Preventiva e Social - FOA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004021074P1') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/76951</xsl:when>
                <!-- Teses - Odontologia Preventiva e Social - FOA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004021074P1') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/76952</xsl:when>
                <!-- Dissertações - Ciências Sociais - FCLAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030017P7') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/76954</xsl:when>
                <!-- Teses - Ciências Sociais - FCLAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030017P7') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/76955</xsl:when>
                <!-- Dissertações - Economia - FCLAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030080P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/76957</xsl:when>
                <!-- Dissertações - Educação Escolar - FCLAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030079P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/76959</xsl:when>
                <!-- Teses - Educação Escolar - FCLAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030079P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/76960</xsl:when>
                <!-- Dissertações - Educação Sexual - FCLAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030083P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/76962</xsl:when>
                <!-- Dissertações - Estudos Literários - FCLAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030016P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/76964</xsl:when>
                <!-- Teses - Estudos Literários - FCLAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030016P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/76965</xsl:when>
                <!-- Dissertações - Linguística e Língua Portuguesa - FCLAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030009P4') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/76967</xsl:when>
                <!-- Teses - Linguística e Língua Portuguesa - FCLAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030009P4') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/76968</xsl:when>
                <!-- Dissertações - Alimentos e Nutrição - FCFAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030055P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/76979</xsl:when>
                <!-- Teses - Alimentos e Nutrição - FCFAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030055P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/76980</xsl:when>
                <!-- Dissertações - Biociências e Biotecnologia Aplicadas à Farmácia - FCFAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030081P7') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/76982</xsl:when>
                <!-- Teses - Biociências e Biotecnologia Aplicadas à Farmácia - FCFAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030081P7') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/76983</xsl:when>
                <!-- Dissertações - Ciências Farmacêuticas - FCFAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030078P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/76985</xsl:when>
                <!-- Teses - Ciências Farmacêuticas - FCFAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030078P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/76986</xsl:when>
            	<!-- Teses - Nanotecnologia Farmacêutica - FCFAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'52001016048P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/109349</xsl:when>
            	<!-- Dissertações - Ciências Odontológicas - FOAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030010P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/76988</xsl:when>
                <!-- Teses - Ciências Odontológicas - FOAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030010P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/76989</xsl:when>
                <!-- Dissertações - Odontologia - FOAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030059P1') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/76992</xsl:when>
                <!-- Teses - Odontologia - FOAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030059P1') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/76993</xsl:when>
                <!-- Dissertações - Reabilitação Oral - FOAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030082P3') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/76994</xsl:when>
                <!-- Teses - Reabilitação Oral - FOAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030082P3') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/76995</xsl:when>
                <!-- Dissertações - Biotecnologia - IQ --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030077P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/76998</xsl:when>
                <!-- Teses - Biotecnologia - IQ --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030077P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/76999</xsl:when>
                <!-- Dissertações - Química - IQ --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030072P8') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77000</xsl:when>
                <!-- Teses - Química - IQ --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030072P8') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77001</xsl:when>
                <!-- Dissertações - Biociências - FCLAS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004048023P9') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77003</xsl:when>
                <!-- Dissertações - História - FCLAS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004048018P5') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77005</xsl:when>
            	<!-- Teses - História - FCLAS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004048018P5') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/109336</xsl:when>
                <!-- Dissertações - Letras - FCLAS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004048019P1') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77007</xsl:when>
                <!-- Teses - Letras - FCLAS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004048019P1') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77008</xsl:when>
                <!-- Dissertações - Psicologia - FCLAS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004048021P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77010</xsl:when>
                <!-- Teses - Psicologia - FCLAS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004048021P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77011</xsl:when>
                <!-- Dissertações - Arquitetura e Urbanismo - FAAC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056090P3') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77013</xsl:when>
                <!-- Dissertações - Comunicação - FAAC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056081P4') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77015</xsl:when>
                <!-- Teses - Comunicação - FAAC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056081P4') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77016</xsl:when>
                <!-- Dissertações - Design - FAAC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056082P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77018</xsl:when>
                <!-- Teses - Design - FAAC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056082P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77019</xsl:when>
                <!-- Dissertações - Televisão Digital: Informação e Conhecimento - FAAC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056088P9') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77021</xsl:when>
                <!-- Dissertações - Ciência e Tecnologia de Materiais - FC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056083P7') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77025</xsl:when>
                <!-- Teses - Ciência e Tecnologia de Materiais - FC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056083P7') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77026</xsl:when>
                <!-- Dissertações - Educação para a Ciência - FC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056079P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77029</xsl:when>
                <!-- Teses - Educação para a Ciência - FC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056079P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77033</xsl:when>
                <!-- Dissertações - Psicologia do Desenvolvimento e Aprendizagem - FC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056085P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77036</xsl:when>
                <!-- Dissertações - Engenharia Civil e Ambiental - FEB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056089P5') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77042</xsl:when>
                <!-- Dissertações - Engenharia de Produção - FEB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056086P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77045</xsl:when>
                <!-- Dissertações - Engenharia Elétrica - FEB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056087P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77050</xsl:when>
                <!-- Dissertações - Engenharia Mecânica - FEB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056080P8') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77052</xsl:when>
                <!-- Teses - Engenharia Mecânica - FEB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056080P8') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77053</xsl:when>
                <!-- Dissertações - Agronomia (Agricultura) - FCA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064039P3') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77062</xsl:when>
                <!-- Teses - Agronomia (Agricultura) - FCA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064039P3') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77063</xsl:when>
                <!-- Dissertações - Agronomia (Energia na Agricultura) - FCA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064021P7') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77073</xsl:when>
                <!-- Teses - Agronomia (Energia na Agricultura) - FCA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064021P7') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77074</xsl:when>
                <!-- Dissertações - Agronomia (Horticultura) - FCA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064014P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77077</xsl:when>
                <!-- Teses - Agronomia (Horticultura) - FCA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064014P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77078</xsl:when>
                <!-- Dissertações - Agronomia (Irrigação e Drenagem) - FCA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064038P7') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77079</xsl:when>
                <!-- Teses - Agronomia (Irrigação e Drenagem) - FCA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064038P7') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77080</xsl:when>
                <!-- Dissertações - Agronomia (Proteção de Plantas) - FCA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064034P1') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77081</xsl:when>
                <!-- Teses - Agronomia (Proteção de Plantas) - FCA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064034P1') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77082</xsl:when>
                <!-- Dissertações - Ciência Florestal - FCA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064082P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77083</xsl:when>
                <!-- Teses - Ciência Florestal - FCA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064082P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77084</xsl:when>
                <!-- Dissertações - Anestesiologia - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064076P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77089</xsl:when>
                <!-- Teses - Anestesiologia - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064076P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77090</xsl:when>
                <!-- Dissertações - Bases Gerais da Cirurgia - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064006P8') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77137</xsl:when>
                <!-- Teses - Bases Gerais da Cirurgia - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064006P8') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77139</xsl:when>
                <!-- Dissertações - Doenças Tropicais - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064065P4') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77144</xsl:when>
                <!-- Teses - Doenças Tropicais - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064065P4') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77146</xsl:when>
                <!-- Dissertações - Enfermagem - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064085P5') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77149</xsl:when>
                <!-- Teses - Enfermagem - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064085P5') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77150</xsl:when>
                <!-- Dissertações - Enfermagem (Mestrado Profissional) - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064081P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77290</xsl:when>
                <!-- Dissertações - Fisiopatologia em Clínica Médica - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064020P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77158</xsl:when>
                <!-- Teses - Fisiopatologia em Clínica Médica - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064020P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77159</xsl:when>
                <!-- Dissertações - Ginecologia, Obstetrícia e Mastologia - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064077P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77161</xsl:when>
                <!-- Teses - Ginecologia, Obstetrícia e Mastologia - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064077P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77162</xsl:when>
                <!-- Dissertações - Patologia - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064056P5') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77167</xsl:when>
                <!-- Teses - Patologia - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064056P5') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77168</xsl:when>
                <!-- Dissertações - Pesquisa e Desenvolvimento (Biotecnologia Médica) - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064079P5') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77172</xsl:when>
                <!-- Dissertações - Saúde Coletiva - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064078P9') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77176</xsl:when>
                <!-- Teses - Saúde Coletiva - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064078P9') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77177</xsl:when>
                <!-- Dissertações - Medicina Veterinária - FMVZ --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064022P3') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77184</xsl:when>
                <!-- Teses - Medicina Veterinária - FMVZ --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064022P3') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77185</xsl:when>
                <!-- Dissertações - Zootecnia - FMVZ --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064048P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77187</xsl:when>
                <!-- Teses - Zootecnia - FMVZ --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064048P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77188</xsl:when>
            	<!-- Dissertações - Dissertações - Biotecnologia Animal - FMVZ --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064086P1') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/110292</xsl:when>
            	<!-- Teses - Teses - Biotecnologia Animal - FMVZ --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064086P1') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/110293</xsl:when>
            	<!-- Dissertações - Biologia Geral e Aplicada - IBB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064080P3') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77190</xsl:when>
                <!-- Teses - Biologia Geral e Aplicada - IBB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064080P3') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77191</xsl:when>
                <!-- Dissertações - Biometria - IBB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064083P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77193</xsl:when>
                <!-- Teses - Biometria - IBB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064083P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77194</xsl:when>
                <!-- Dissertações - Ciências Biológicas (Botânica) - IBB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064025P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77199</xsl:when>
                <!-- Teses - Ciências Biológicas (Botânica) - IBB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064025P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77201</xsl:when>
                <!-- Dissertações - Ciências Biológicas (Farmacologia) - IBB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064052P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77210</xsl:when>
                <!-- Teses - Ciências Biológicas (Farmacologia) - IBB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064052P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77211</xsl:when>
                <!-- Dissertações - Ciências Biológicas (Genética) - IBB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064026P9') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77214</xsl:when>
                <!-- Teses - Ciências Biológicas (Genética) - IBB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064026P9') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77215</xsl:when>
                <!-- Dissertações - Ciências Biológicas (Zoologia) - IBB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064012P8') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77221</xsl:when>
                <!-- Teses - Ciências Biológicas (Zoologia) - IBB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064012P8') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77222</xsl:when>
                <!-- Dissertações - Direito - FCHS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004072068P9') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77230</xsl:when>
                <!-- Dissertações - História - FCHS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004072013P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77236</xsl:when>
                <!-- Teses - História - FCHS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004072013P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77239</xsl:when>
                <!-- Dissertações - Planejamento e Análise de Políticas Públicas - FCHS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004072069P5') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77245</xsl:when>
                <!-- Dissertações - Serviço Social - FCHS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004072067P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77247</xsl:when>
                <!-- Teses - Serviço Social - FCHS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004072067P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77248</xsl:when>
                <!-- Dissertações - Engenharia de Produção - FEG --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004080052P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77262</xsl:when>
                <!-- Dissertações - Engenharia Mecânica - FEG --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004080027P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77263</xsl:when>
                <!-- Teses - Engenharia Mecânica - FEG --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004080027P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77264</xsl:when>
                <!-- Dissertações - Física - FEG --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004080051P4') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77267</xsl:when>
                <!-- Teses - Física - FEG --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004080051P4') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77269</xsl:when>
                <!-- Dissertações - Agronomia - FEIS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099079P1') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77271</xsl:when>
                <!-- Teses - Agronomia - FEIS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099079P1') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77272</xsl:when>
                <!-- Dissertações - Ciência dos Materiais - FEIS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099083P9') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77275</xsl:when>
                <!-- Teses - Ciência dos Materiais - FEIS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099083P9') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77277</xsl:when>
                <!-- Dissertações - Ciência e Tecnologia Animal - FEIS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099086P8') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77280</xsl:when>
                <!-- Dissertações - Engenharia Civil - FEIS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099084P5') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77282</xsl:when>
                <!-- Dissertações - Engenharia Elétrica - FEIS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099080P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77276</xsl:when>
                <!-- Teses - Engenharia Elétrica - FEIS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099080P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77278</xsl:when>
                <!-- Dissertações - Engenharia Mecânica - FEIS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099082P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77266</xsl:when>
                <!-- Teses - Engenharia Mecânica - FEIS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099082P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77268</xsl:when>
                <!-- Dissertações - Agronomia (Ciência do Solo) - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102071P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77254</xsl:when>
                <!-- Teses - Agronomia (Ciência do Solo) - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102071P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77255</xsl:when>
                <!-- Dissertações - Agronomia (Entomologia Agrícola) - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102037P9') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77257</xsl:when>
                <!-- Teses - Agronomia (Entomologia Agrícola) - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102037P9') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77258</xsl:when>
                <!-- Dissertações - Agronomia (Genética e Melhoramento de Plantas) - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102029P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77250</xsl:when>
                <!-- Teses - Agronomia (Genética e Melhoramento de Plantas) - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102029P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77251</xsl:when>
                <!-- Dissertações - Agronomia (Produção Vegetal) - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102001P4') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77243</xsl:when>
                <!-- Teses - Agronomia (Produção Vegetal) - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102001P4') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77244</xsl:when>
                <!-- Dissertações - Aquicultura - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102049P7') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77238</xsl:when>
                <!-- Teses - Aquicultura - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102049P7') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77240</xsl:when>
                <!-- Dissertações - Cirurgia Veterinária - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102069P8') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77284</xsl:when>
                <!-- Teses - Cirurgia Veterinária - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102069P8') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77285</xsl:when>
                <!-- Dissertações - Genética e Melhoramento Animal - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102030P4') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77233</xsl:when>
                <!-- Teses - Genética e Melhoramento Animal - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102030P4') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77234</xsl:when>
                <!-- Dissertações - Medicina Veterinária - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102072P9') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77227</xsl:when>
                <!-- Teses - Medicina Veterinária - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102072P9') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77228</xsl:when>
                <!-- Dissertações - Microbiologia Agropecuária - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102070P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77224</xsl:when>
                <!-- Teses - Microbiologia Agropecuária - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102070P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77225</xsl:when>
                <!-- Dissertações - Zootecnia - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102002P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77217</xsl:when>
                <!-- Teses - Zootecnia - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102002P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77218</xsl:when>
                <!-- Dissertações - Ciência da Informação - FFC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110043P4') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/61308</xsl:when>
                <!-- Teses - Ciência da Informação - FFC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110043P4') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/60543</xsl:when>
                <!-- Dissertações - Ciências Sociais - FFC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110042P8') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/63569</xsl:when>
                <!-- Teses - Ciências Sociais - FFC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110042P8') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/63571</xsl:when>
                <!-- Dissertações - Educação - FFC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110040P5') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/63577</xsl:when>
                <!-- Teses - Educação - FFC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110040P5') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/63579</xsl:when>
                <!-- Dissertações - Filosofia - FFC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110041P1') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/63583</xsl:when>
                <!-- Dissertações - Fonoaudiologia - FFC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110045P7') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/63591</xsl:when>
                <!-- Dissertações - Relações internacionais (UNESP - UNICAMP - PUC-SP) - FFC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110044P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77287</xsl:when>
                <!-- Teses - Relações internacionais (UNESP - UNICAMP - PUC-SP) - FFC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110044P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77288</xsl:when>
                <!-- Dissertações - Ciências Cartográficas - FCT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129043P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77208</xsl:when>
                <!-- Teses - Ciências Cartográficas - FCT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129043P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77209</xsl:when>
                <!-- Dissertações - Educação - FCT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129044P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77204</xsl:when>
                <!-- Teses - Educação - FCT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129044P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77205</xsl:when>
                <!-- Dissertações - Fisioterapia - FCT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129045P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77202</xsl:when>
                <!-- Dissertações - Geografia - FCT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129042P3') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77196</xsl:when>
                <!-- Teses - Geografia - FCT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129042P3') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77197</xsl:when>
                <!-- Dissertações - Geografia [Mestrado Profissional] - FCT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129047P5') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77182</xsl:when>
                <!-- Dissertações - Matematica Aplicada e Computacional - FCT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129046P9') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77180</xsl:when>
                <!-- Dissertações - Ciências Biológicas (Biologia Celular e Molecular) - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137046P4') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77030</xsl:when>
                <!-- Teses - Ciências Biológicas (Biologia Celular e Molecular) - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137046P4') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77032</xsl:when>
                <!-- Dissertações - Ciências Biológicas (Biologia Vegetal) - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137005P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77037</xsl:when>
                <!-- Teses - Ciências Biológicas (Biologia Vegetal) - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137005P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77038</xsl:when>
                <!-- Dissertações - Ciências Biológicas (Microbiologia Aplicada) - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137041P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77041</xsl:when>
                <!-- Teses - Ciências Biológicas (Microbiologia Aplicada) - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137041P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77043</xsl:when>
                <!-- Dissertações - Ciências Biológicas (Zoologia) - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137003P3') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77047</xsl:when>
                <!-- Teses - Ciências Biológicas (Zoologia) - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137003P3') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77048</xsl:when>
                <!-- Dissertações - Ciências da Motricidade - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137062P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77064</xsl:when>
                <!-- Teses - Ciências da Motricidade - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137062P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77065</xsl:when>
                <!-- Dissertações - Desenvolvimento Humano e Tecnologias - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137066P5') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77067</xsl:when>
                <!-- Teses - Desenvolvimento Humano e Tecnologias - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137066P5') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77068</xsl:when>
                <!-- Dissertações - Ecologia e Biodiversidade - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137067P1') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77070</xsl:when>
                <!-- Teses - Ecologia e Biodiversidade - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137067P1') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77071</xsl:when>
                <!-- Dissertações - Educação - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137064P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77075</xsl:when>
                <!-- Teses - Educação - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137064P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77076</xsl:when>
                <!-- Dissertações - Educação Matemática - IGCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137031P7') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77087</xsl:when>
                <!-- Teses - Educação Matemática - IGCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137031P7') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77088</xsl:when>
                <!-- Dissertações - Física - IGCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137063P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77092</xsl:when>
                <!-- Dissertações - Geociências e Meio Ambiente - IGCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137036P9') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77094</xsl:when>
                <!-- Teses - Geociências e Meio Ambiente - IGCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137036P9') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77095</xsl:when>
                <!-- Dissertações - Geografia - IGCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137004P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77097</xsl:when>
                <!-- Teses - Geografia - IGCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137004P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77098</xsl:when>
                <!-- Dissertações - Geologia Regional - IGCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137035P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77100</xsl:when>
                <!-- Teses - Geologia Regional - IGCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137035P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77101</xsl:when>
                <!-- Dissertações - Matemática Universitária - IGCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137065P9') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77103</xsl:when>
                <!-- Dissertações - Biofísica Molecular - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153068P9') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77106</xsl:when>
                <!-- Teses - Biofísica Molecular - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153068P9') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77107</xsl:when>
                <!-- Dissertações - Biologia Animal - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153072P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77109</xsl:when>
                <!-- Teses - Biologia Animal - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153072P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77110</xsl:when>
                <!-- Dissertações - Ciência da Computação - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153073P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77112</xsl:when>
                <!-- Dissertações - Engenharia e Ciência de Alimentos - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153070P3') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77114</xsl:when>
                <!-- Teses - Engenharia e Ciência de Alimentos - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153070P3') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77115</xsl:when>
                <!-- Dissertações - Estudos Linguísticos - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153069P5') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77117</xsl:when>
                <!-- Teses - Estudos Linguísticos - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153069P5') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77118</xsl:when>
                <!-- Dissertações - Genética - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153023P5') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77120</xsl:when>
                <!-- Teses - Genética - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153023P5') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77121</xsl:when>
                <!-- Dissertações - Letras - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153015P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77123</xsl:when>
                <!-- Teses - Letras - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153015P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77124</xsl:when>
                <!-- Dissertações - Matemática - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153071P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77126</xsl:when>
                <!-- Teses - Matemática - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153071P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77127</xsl:when>
                <!-- Dissertações - Matemática em Rede Nacional - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'31075010001P2') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77129</xsl:when>
                <!-- Dissertações - Microbiologia - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153074P9') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77131</xsl:when>
                <!-- Teses - Microbiologia - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153074P9') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77132</xsl:when>
                <!-- Dissertações - Química - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153077P8') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77135</xsl:when>
                <!-- Dissertações - Biopatologia Bucal - ICT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004145081P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77138</xsl:when>
                <!-- Teses - Biopatologia Bucal - ICT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004145081P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77140</xsl:when>
                <!-- Dissertações - Odontologia Restauradora - ICT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004145070P8') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77143</xsl:when>
                <!-- Teses - Odontologia Restauradora - ICT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004145070P8') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77145</xsl:when>
                <!-- Dissertações - Artes - IA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004013063P4') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77152</xsl:when>
                <!-- Teses - Artes - IA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004013063P4') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77153</xsl:when>
                <!-- Dissertações - Música - IA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004013066P3') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77155</xsl:when>
                <!-- Teses - Música - IA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004013066P3') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77156</xsl:when>
                <!-- Dissertações - Física - IFT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33015015001P7') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77164</xsl:when>
                <!-- Teses - Física - IFT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33015015001P7') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77166</xsl:when>
                <!-- Dissertações - Desenvolvimento Territorial na América Latina e Caribe - IPPRI --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004013068P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77171</xsl:when>
                <!-- Dissertações - Ciências Ambientais - Sorocaba --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004170001P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77175</xsl:when>
                <!-- Teses - Ciências Ambientais - Sorocaba --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004170001P6') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77178</xsl:when>
                <!-- Dissertações - Agronegócio e Desenvolvimento - Tupã --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004188001P8') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77023</xsl:when>
                
                <!-- MARC 695[2] -->
                
                <!-- Dissertações - Ciência Animal - FMVA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004021075P8') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/63600</xsl:when>
                <!-- Teses - Ciência Animal - FMVA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004021075P8') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/76943</xsl:when>
                <!-- Dissertações - Ciência odontólogica - FOA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004021073P5') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/76945</xsl:when>
                <!-- Teses - Ciência odontólogica - FOA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004021073P5') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/76946</xsl:when>
                <!-- Dissertações - Odontologia - FOA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004021011P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/76949</xsl:when>
                <!-- Teses - Odontologia - FOA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004021011P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/76950</xsl:when>
                <!-- Dissertações - Odontologia Preventiva e Social - FOA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004021074P1') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/76951</xsl:when>
                <!-- Teses - Odontologia Preventiva e Social - FOA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004021074P1') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/76952</xsl:when>
                <!-- Dissertações - Ciências Sociais - FCLAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030017P7') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/76954</xsl:when>
                <!-- Teses - Ciências Sociais - FCLAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030017P7') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/76955</xsl:when>
                <!-- Dissertações - Economia - FCLAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030080P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/76957</xsl:when>
                <!-- Dissertações - Educação Escolar - FCLAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030079P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/76959</xsl:when>
                <!-- Teses - Educação Escolar - FCLAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030079P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/76960</xsl:when>
                <!-- Dissertações - Educação Sexual - FCLAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030083P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/76962</xsl:when>
                <!-- Dissertações - Estudos Literários - FCLAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030016P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/76964</xsl:when>
                <!-- Teses - Estudos Literários - FCLAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030016P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/76965</xsl:when>
                <!-- Dissertações - Linguística e Língua Portuguesa - FCLAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030009P4') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/76967</xsl:when>
                <!-- Teses - Linguística e Língua Portuguesa - FCLAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030009P4') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/76968</xsl:when>
                <!-- Dissertações - Alimentos e Nutrição - FCFAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030055P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/76979</xsl:when>
                <!-- Teses - Alimentos e Nutrição - FCFAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030055P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/76980</xsl:when>
                <!-- Dissertações - Biociências e Biotecnologia Aplicadas à Farmácia - FCFAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030081P7') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/76982</xsl:when>
                <!-- Teses - Biociências e Biotecnologia Aplicadas à Farmácia - FCFAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030081P7') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/76983</xsl:when>
                <!-- Dissertações - Ciências Farmacêuticas - FCFAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030078P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/76985</xsl:when>
                <!-- Teses - Ciências Farmacêuticas - FCFAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030078P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/76986</xsl:when>
            	<!-- Teses - Nanotecnologia Farmacêutica - FCFAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'52001016048P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/109349</xsl:when>
            	<!-- Dissertações - Ciências Odontológicas - FOAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030010P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/76988</xsl:when>
                <!-- Teses - Ciências Odontológicas - FOAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030010P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/76989</xsl:when>
                <!-- Dissertações - Odontologia - FOAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030059P1') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/76992</xsl:when>
                <!-- Teses - Odontologia - FOAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030059P1') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/76993</xsl:when>
                <!-- Dissertações - Reabilitação Oral - FOAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030082P3') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/76994</xsl:when>
                <!-- Teses - Reabilitação Oral - FOAR --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030082P3') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/76995</xsl:when>
                <!-- Dissertações - Biotecnologia - IQ --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030077P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/76998</xsl:when>
                <!-- Teses - Biotecnologia - IQ --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030077P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/76999</xsl:when>
                <!-- Dissertações - Química - IQ --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030072P8') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77000</xsl:when>
                <!-- Teses - Química - IQ --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004030072P8') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77001</xsl:when>
                <!-- Dissertações - Biociências - FCLAS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004048023P9') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77003</xsl:when>
                <!-- Dissertações - História - FCLAS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004048018P5') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77005</xsl:when>
                <!-- Teses - História - FCLAS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004048018P5') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77005</xsl:when>
                <!-- Dissertações - Letras - FCLAS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004048019P1') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77007</xsl:when>
                <!-- Teses - Letras - FCLAS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004048019P1') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77008</xsl:when>
                <!-- Dissertações - Psicologia - FCLAS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004048021P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77010</xsl:when>
                <!-- Teses - Psicologia - FCLAS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004048021P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77011</xsl:when>
                <!-- Dissertações - Arquitetura e Urbanismo - FAAC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056090P3') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77013</xsl:when>
                <!-- Dissertações - Comunicação - FAAC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056081P4') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77015</xsl:when>
                <!-- Teses - Comunicação - FAAC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056081P4') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77016</xsl:when>
                <!-- Dissertações - Design - FAAC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056082P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77018</xsl:when>
                <!-- Teses - Design - FAAC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056082P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77019</xsl:when>
                <!-- Dissertações - Televisão Digital: Informação e Conhecimento - FAAC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056088P9') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77021</xsl:when>
                <!-- Dissertações - Ciência e Tecnologia de Materiais - FC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056083P7') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77025</xsl:when>
                <!-- Teses - Ciência e Tecnologia de Materiais - FC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056083P7') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77026</xsl:when>
                <!-- Dissertações - Educação para a Ciência - FC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056079P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77029</xsl:when>
                <!-- Teses - Educação para a Ciência - FC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056079P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77033</xsl:when>
                <!-- Dissertações - Psicologia do Desenvolvimento e Aprendizagem - FC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056085P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77036</xsl:when>
                <!-- Dissertações - Engenharia Civil e Ambiental - FEB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056089P5') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77042</xsl:when>
                <!-- Dissertações - Engenharia de Produção - FEB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056086P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77045</xsl:when>
                <!-- Dissertações - Engenharia Elétrica - FEB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056087P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77050</xsl:when>
                <!-- Dissertações - Engenharia Mecânica - FEB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056080P8') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77052</xsl:when>
                <!-- Teses - Engenharia Mecânica - FEB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004056080P8') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77053</xsl:when>
                <!-- Dissertações - Agronomia (Agricultura) - FCA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064039P3') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77062</xsl:when>
                <!-- Teses - Agronomia (Agricultura) - FCA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064039P3') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77063</xsl:when>
                <!-- Dissertações - Agronomia (Energia na Agricultura) - FCA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064021P7') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77073</xsl:when>
                <!-- Teses - Agronomia (Energia na Agricultura) - FCA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064021P7') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77074</xsl:when>
                <!-- Dissertações - Agronomia (Horticultura) - FCA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064014P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77077</xsl:when>
                <!-- Teses - Agronomia (Horticultura) - FCA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064014P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77078</xsl:when>
                <!-- Dissertações - Agronomia (Irrigação e Drenagem) - FCA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064038P7') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77079</xsl:when>
                <!-- Teses - Agronomia (Irrigação e Drenagem) - FCA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064038P7') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77080</xsl:when>
                <!-- Dissertações - Agronomia (Proteção de Plantas) - FCA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064034P1') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77081</xsl:when>
                <!-- Teses - Agronomia (Proteção de Plantas) - FCA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064034P1') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77082</xsl:when>
                <!-- Dissertações - Ciência Florestal - FCA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064082P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77083</xsl:when>
                <!-- Teses - Ciência Florestal - FCA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064082P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77084</xsl:when>
                <!-- Dissertações - Anestesiologia - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064076P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77089</xsl:when>
                <!-- Teses - Anestesiologia - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064076P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77090</xsl:when>
                <!-- Dissertações - Bases Gerais da Cirurgia - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064006P8') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77137</xsl:when>
                <!-- Teses - Bases Gerais da Cirurgia - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064006P8') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77139</xsl:when>
                <!-- Dissertações - Doenças Tropicais - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064065P4') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77144</xsl:when>
                <!-- Teses - Doenças Tropicais - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064065P4') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77146</xsl:when>
                <!-- Dissertações - Enfermagem - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064085P5') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77149</xsl:when>
                <!-- Teses - Enfermagem - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064085P5') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77150</xsl:when>
                <!-- Dissertações - Enfermagem (Mestrado Profissional) - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064081P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77290</xsl:when>
                <!-- Dissertações - Fisiopatologia em Clínica Médica - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064020P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77158</xsl:when>
                <!-- Teses - Fisiopatologia em Clínica Médica - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064020P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77159</xsl:when>
                <!-- Dissertações - Ginecologia, Obstetrícia e Mastologia - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064077P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77161</xsl:when>
                <!-- Teses - Ginecologia, Obstetrícia e Mastologia - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064077P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77162</xsl:when>
                <!-- Dissertações - Patologia - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064056P5') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77167</xsl:when>
                <!-- Teses - Patologia - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064056P5') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77168</xsl:when>
                <!-- Dissertações - Pesquisa e Desenvolvimento (Biotecnologia Médica) - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064079P5') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77172</xsl:when>
                <!-- Dissertações - Saúde Coletiva - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064078P9') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77176</xsl:when>
                <!-- Teses - Saúde Coletiva - FMB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064078P9') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77177</xsl:when>
                <!-- Dissertações - Medicina Veterinária - FMVZ --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064022P3') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77184</xsl:when>
                <!-- Teses - Medicina Veterinária - FMVZ --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064022P3') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77185</xsl:when>
                <!-- Dissertações - Zootecnia - FMVZ --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064048P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77187</xsl:when>
                <!-- Teses - Zootecnia - FMVZ --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064048P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77188</xsl:when>
            	<!-- Dissertações - Dissertações - Biotecnologia Animal - FMVZ --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064086P1') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/110292</xsl:when>
            	<!-- Teses - Teses - Biotecnologia Animal - FMVZ --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064086P1') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/110293</xsl:when>
            	<!-- Dissertações - Biologia Geral e Aplicada - IBB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064080P3') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77190</xsl:when>
                <!-- Teses - Biologia Geral e Aplicada - IBB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064080P3') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77191</xsl:when>
                <!-- Dissertações - Biometria - IBB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064083P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77193</xsl:when>
                <!-- Teses - Biometria - IBB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064083P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77194</xsl:when>
                <!-- Dissertações - Ciências Biológicas (Botânica) - IBB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064025P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77199</xsl:when>
                <!-- Teses - Ciências Biológicas (Botânica) - IBB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064025P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77201</xsl:when>
                <!-- Dissertações - Ciências Biológicas (Farmacologia) - IBB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064052P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77210</xsl:when>
                <!-- Teses - Ciências Biológicas (Farmacologia) - IBB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064052P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77211</xsl:when>
                <!-- Dissertações - Ciências Biológicas (Genética) - IBB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064026P9') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77214</xsl:when>
                <!-- Teses - Ciências Biológicas (Genética) - IBB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064026P9') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77215</xsl:when>
                <!-- Dissertações - Ciências Biológicas (Zoologia) - IBB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064012P8') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77221</xsl:when>
                <!-- Teses - Ciências Biológicas (Zoologia) - IBB --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004064012P8') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77222</xsl:when>
                <!-- Dissertações - Direito - FCHS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004072068P9') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77230</xsl:when>
                <!-- Dissertações - História - FCHS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004072013P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77236</xsl:when>
                <!-- Teses - História - FCHS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004072013P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77239</xsl:when>
                <!-- Dissertações - Planejamento e Análise de Políticas Públicas - FCHS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004072069P5') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77245</xsl:when>
                <!-- Dissertações - Serviço Social - FCHS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004072067P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77247</xsl:when>
                <!-- Teses - Serviço Social - FCHS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004072067P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77248</xsl:when>
                <!-- Dissertações - Engenharia de Produção - FEG --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004080052P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77262</xsl:when>
                <!-- Dissertações - Engenharia Mecânica - FEG --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004080027P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77263</xsl:when>
                <!-- Teses - Engenharia Mecânica - FEG --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004080027P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77264</xsl:when>
                <!-- Dissertações - Física - FEG --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004080051P4') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77267</xsl:when>
                <!-- Teses - Física - FEG --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004080051P4') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77269</xsl:when>
                <!-- Dissertações - Agronomia - FEIS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099079P1') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77271</xsl:when>
                <!-- Teses - Agronomia - FEIS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099079P1') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77272</xsl:when>
                <!-- Dissertações - Ciência dos Materiais - FEIS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099083P9') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77275</xsl:when>
                <!-- Teses - Ciência dos Materiais - FEIS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099083P9') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77277</xsl:when>
                <!-- Dissertações - Ciência e Tecnologia Animal - FEIS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099086P8') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77280</xsl:when>
                <!-- Dissertações - Engenharia Civil - FEIS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099084P5') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77282</xsl:when>
                <!-- Dissertações - Engenharia Elétrica - FEIS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099080P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77276</xsl:when>
                <!-- Teses - Engenharia Elétrica - FEIS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099080P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77278</xsl:when>
                <!-- Dissertações - Engenharia Mecânica - FEIS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099082P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77266</xsl:when>
                <!-- Teses - Engenharia Mecânica - FEIS --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004099082P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77268</xsl:when>
                <!-- Dissertações - Agronomia (Ciência do Solo) - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102071P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77254</xsl:when>
                <!-- Teses - Agronomia (Ciência do Solo) - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102071P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77255</xsl:when>
                <!-- Dissertações - Agronomia (Entomologia Agrícola) - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102037P9') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77257</xsl:when>
                <!-- Teses - Agronomia (Entomologia Agrícola) - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102037P9') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77258</xsl:when>
                <!-- Dissertações - Agronomia (Genética e Melhoramento de Plantas) - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102029P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77250</xsl:when>
                <!-- Teses - Agronomia (Genética e Melhoramento de Plantas) - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102029P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77251</xsl:when>
                <!-- Dissertações - Agronomia (Produção Vegetal) - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102001P4') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77243</xsl:when>
                <!-- Teses - Agronomia (Produção Vegetal) - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102001P4') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77244</xsl:when>
                <!-- Dissertações - Aquicultura - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102049P7') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77238</xsl:when>
                <!-- Teses - Aquicultura - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102049P7') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77240</xsl:when>
                <!-- Dissertações - Cirurgia Veterinária - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102069P8') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77284</xsl:when>
                <!-- Teses - Cirurgia Veterinária - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102069P8') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77285</xsl:when>
                <!-- Dissertações - Genética e Melhoramento Animal - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102030P4') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77233</xsl:when>
                <!-- Teses - Genética e Melhoramento Animal - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102030P4') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77234</xsl:when>
                <!-- Dissertações - Medicina Veterinária - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102072P9') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77227</xsl:when>
                <!-- Teses - Medicina Veterinária - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102072P9') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77228</xsl:when>
                <!-- Dissertações - Microbiologia Agropecuária - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102070P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77224</xsl:when>
                <!-- Teses - Microbiologia Agropecuária - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102070P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77225</xsl:when>
                <!-- Dissertações - Zootecnia - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102002P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77217</xsl:when>
                <!-- Teses - Zootecnia - FCAV --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004102002P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77218</xsl:when>
                <!-- Dissertações - Ciência da Informação - FFC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110043P4') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/61308</xsl:when>
                <!-- Teses - Ciência da Informação - FFC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110043P4') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/60543</xsl:when>
                <!-- Dissertações - Ciências Sociais - FFC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110042P8') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/63569</xsl:when>
                <!-- Teses - Ciências Sociais - FFC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110042P8') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/63571</xsl:when>
                <!-- Dissertações - Educação - FFC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110040P5') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/63577</xsl:when>
                <!-- Teses - Educação - FFC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110040P5') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/63579</xsl:when>
                <!-- Dissertações - Filosofia - FFC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110041P1') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/63583</xsl:when>
                <!-- Dissertações - Fonoaudiologia - FFC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110045P7') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/63591</xsl:when>
                <!-- Dissertações - Relações internacionais (UNESP - UNICAMP - PUC-SP) - FFC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110044P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TM')">11449/77287</xsl:when>
                <!-- Teses - Relações internacionais (UNESP - UNICAMP - PUC-SP) - FFC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004110044P0') and contains(datafield[@tag=695][1]/subfield[@code='a'],'TD')">11449/77288</xsl:when>
                <!-- Dissertações - Ciências Cartográficas - FCT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129043P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77208</xsl:when>
                <!-- Teses - Ciências Cartográficas - FCT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129043P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77209</xsl:when>
                <!-- Dissertações - Educação - FCT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129044P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77204</xsl:when>
                <!-- Teses - Educação - FCT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129044P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77205</xsl:when>
                <!-- Dissertações - Fisioterapia - FCT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129045P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77202</xsl:when>
                <!-- Dissertações - Geografia - FCT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129042P3') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77196</xsl:when>
                <!-- Teses - Geografia - FCT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129042P3') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77197</xsl:when>
                <!-- Dissertações - Geografia [Mestrado Profissional] - FCT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129047P5') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77182</xsl:when>
                <!-- Dissertações - Matematica Aplicada e Computacional - FCT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004129046P9') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77180</xsl:when>
                <!-- Dissertações - Ciências Biológicas (Biologia Celular e Molecular) - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137046P4') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77030</xsl:when>
                <!-- Teses - Ciências Biológicas (Biologia Celular e Molecular) - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137046P4') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77032</xsl:when>
                <!-- Dissertações - Ciências Biológicas (Biologia Vegetal) - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137005P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77037</xsl:when>
                <!-- Teses - Ciências Biológicas (Biologia Vegetal) - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137005P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77038</xsl:when>
                <!-- Dissertações - Ciências Biológicas (Microbiologia Aplicada) - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137041P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77041</xsl:when>
                <!-- Teses - Ciências Biológicas (Microbiologia Aplicada) - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137041P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77043</xsl:when>
                <!-- Dissertações - Ciências Biológicas (Zoologia) - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137003P3') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77047</xsl:when>
                <!-- Teses - Ciências Biológicas (Zoologia) - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137003P3') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77048</xsl:when>
                <!-- Dissertações - Ciências da Motricidade - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137062P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77064</xsl:when>
                <!-- Teses - Ciências da Motricidade - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137062P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77065</xsl:when>
                <!-- Dissertações - Desenvolvimento Humano e Tecnologias - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137066P5') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77067</xsl:when>
                <!-- Teses - Desenvolvimento Humano e Tecnologias - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137066P5') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77068</xsl:when>
                <!-- Dissertações - Ecologia e Biodiversidade - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137067P1') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77070</xsl:when>
                <!-- Teses - Ecologia e Biodiversidade - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137067P1') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77071</xsl:when>
                <!-- Dissertações - Educação - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137064P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77075</xsl:when>
                <!-- Teses - Educação - IBRC --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137064P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77076</xsl:when>
                <!-- Dissertações - Educação Matemática - IGCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137031P7') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77087</xsl:when>
                <!-- Teses - Educação Matemática - IGCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137031P7') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77088</xsl:when>
                <!-- Dissertações - Física - IGCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137063P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77092</xsl:when>
                <!-- Dissertações - Geociências e Meio Ambiente - IGCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137036P9') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77094</xsl:when>
                <!-- Teses - Geociências e Meio Ambiente - IGCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137036P9') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77095</xsl:when>
                <!-- Dissertações - Geografia - IGCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137004P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77097</xsl:when>
                <!-- Teses - Geografia - IGCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137004P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77098</xsl:when>
                <!-- Dissertações - Geologia Regional - IGCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137035P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77100</xsl:when>
                <!-- Teses - Geologia Regional - IGCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137035P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77101</xsl:when>
                <!-- Dissertações - Matemática Universitária - IGCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004137065P9') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77103</xsl:when>
                <!-- Dissertações - Biofísica Molecular - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153068P9') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77106</xsl:when>
                <!-- Teses - Biofísica Molecular - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153068P9') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77107</xsl:when>
                <!-- Dissertações - Biologia Animal - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153072P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77109</xsl:when>
                <!-- Teses - Biologia Animal - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153072P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77110</xsl:when>
                <!-- Dissertações - Ciência da Computação - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153073P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77112</xsl:when>
                <!-- Dissertações - Engenharia e Ciência de Alimentos - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153070P3') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77114</xsl:when>
                <!-- Teses - Engenharia e Ciência de Alimentos - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153070P3') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77115</xsl:when>
                <!-- Dissertações - Estudos Linguísticos - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153069P5') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77117</xsl:when>
                <!-- Teses - Estudos Linguísticos - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153069P5') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77118</xsl:when>
                <!-- Dissertações - Genética - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153023P5') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77120</xsl:when>
                <!-- Teses - Genética - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153023P5') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77121</xsl:when>
                <!-- Dissertações - Letras - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153015P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77123</xsl:when>
                <!-- Teses - Letras - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153015P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77124</xsl:when>
                <!-- Dissertações - Matemática - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153071P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77126</xsl:when>
                <!-- Teses - Matemática - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153071P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77127</xsl:when>
                <!-- Dissertações - Matemática em Rede Nacional - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'31075010001P2') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77129</xsl:when>
                <!-- Dissertações - Microbiologia - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153074P9') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77131</xsl:when>
                <!-- Teses - Microbiologia - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153074P9') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77132</xsl:when>
                <!-- Dissertações - Química - IBILCE --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004153077P8') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77135</xsl:when>
                <!-- Dissertações - Biopatologia Bucal - ICT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004145081P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77138</xsl:when>
                <!-- Teses - Biopatologia Bucal - ICT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004145081P0') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77140</xsl:when>
                <!-- Dissertações - Odontologia Restauradora - ICT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004145070P8') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77143</xsl:when>
                <!-- Teses - Odontologia Restauradora - ICT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004145070P8') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77145</xsl:when>
                <!-- Dissertações - Artes - IA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004013063P4') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77152</xsl:when>
                <!-- Teses - Artes - IA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004013063P4') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77153</xsl:when>
                <!-- Dissertações - Música - IA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004013066P3') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77155</xsl:when>
                <!-- Teses - Música - IA --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004013066P3') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77156</xsl:when>
                <!-- Dissertações - Física - IFT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33015015001P7') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77164</xsl:when>
                <!-- Teses - Física - IFT --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33015015001P7') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77166</xsl:when>
                <!-- Dissertações - Desenvolvimento Territorial na América Latina e Caribe - IPPRI --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004013068P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77171</xsl:when>
                <!-- Dissertações - Ciências Ambientais - Sorocaba --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004170001P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77175</xsl:when>
                <!-- Teses - Ciências Ambientais - Sorocaba --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004170001P6') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TD')">11449/77178</xsl:when>
                <!-- Dissertações - Agronegócio e Desenvolvimento - Tupã --><xsl:when test="contains(datafield[@tag=942]/subfield[@code='b'],'33004188001P8') and contains(datafield[@tag=695][2]/subfield[@code='a'],'TM')">11449/77023</xsl:when>
                
                <!-- Caso o registro pertença a nenhuma das coleções, será indicado "Verificação - Dissertações e teses" -->
                
            	<xsl:otherwise>11449/77291</xsl:otherwise>
            </xsl:choose>
        </collection>
        
    </xsl:template>
</xsl:stylesheet>
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:functx="http://www.functx.com"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<!-- Folha de estilo para extração dos dados do Currículo Lattes e 
		conversão em registro para importação no Repositório Institucional UNESP 
	
	Última atualização: 2015-03-31
	-->
	
	<xsl:output method="xml" indent="yes" version="1.0" encoding="UTF-8" omit-xml-declaration="no"/>
	
	<!-- Funções não nativas -->
	
	<xsl:function name="functx:escape-for-regex" as="xs:string">
		<xsl:param name="arg" as="xs:string?"/>
		<xsl:sequence select="
			replace($arg,
			'(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
			"/>
	</xsl:function>
	
	<xsl:function name="functx:substring-after-last" as="xs:string">
		<xsl:param name="arg" as="xs:string?"/>
		<xsl:param name="delim" as="xs:string"/>
		<xsl:sequence select="
			replace ($arg,concat('^.*',functx:escape-for-regex($delim)),'')
			"/>
	</xsl:function>
	
	<xsl:function name="functx:substring-before-last" as="xs:string">
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
	
	<!-- Template inicial -->
	
	<xsl:template match="/">
		<records>
			<xsl:for-each select="curriculos/CURRICULO-VITAE/PRODUCAO-BIBLIOGRAFICA/ARTIGOS-PUBLICADOS/ARTIGO-PUBLICADO">
				<xsl:call-template name="record" />
			</xsl:for-each>
		</records>
	</xsl:template>
	
	<!-- Template record -->
	
	<xsl:template name="record">
		<dublin_core schema="dc"> 
			
			<xsl:variable name="autorLattes">
				<xsl:value-of select="ancestor::node()[3]/DADOS-GERAIS/@NOME-COMPLETO"/>
			</xsl:variable>
			
			<xsl:variable name="autorLattesId">
				<xsl:value-of select="ancestor::node()[3]/@NUMERO-IDENTIFICADOR"/>
			</xsl:variable>
			
			<!-- dc.contributor.author -->
			
			<xsl:for-each select="AUTORES">
				
				<dcvalue element="contributor" qualifier="author">		
					<xsl:variable name="authorName">
						<xsl:choose>
							
							<xsl:when test="@NOME-COMPLETO-DO-AUTOR = upper-case(@NOME-COMPLETO-DO-AUTOR)">
								<xsl:call-template name="CamelCase">
									<xsl:with-param name="text">
										<xsl:value-of select="@NOME-COMPLETO-DO-AUTOR"/>
									</xsl:with-param>
								</xsl:call-template>
							</xsl:when>
							
							<xsl:when test="functx:substring-after-last(@NOME-COMPLETO-DO-AUTOR,' ') = upper-case(functx:substring-after-last(@NOME-COMPLETO-DO-AUTOR,' '))">
								<xsl:call-template name="CamelCase">
									<xsl:with-param name="text">
										<xsl:value-of select="@NOME-COMPLETO-DO-AUTOR"/>
									</xsl:with-param>
								</xsl:call-template>
							</xsl:when>
							
							<xsl:when test="contains(@NOME-COMPLETO-DO-AUTOR,',') 
								and substring-before(@NOME-COMPLETO-DO-AUTOR,',') = upper-case(substring-before(@NOME-COMPLETO-DO-AUTOR,','))">
								<xsl:call-template name="CamelCase">
									<xsl:with-param name="text">
										<xsl:value-of select="@NOME-COMPLETO-DO-AUTOR"/>
									</xsl:with-param>
								</xsl:call-template>
							</xsl:when>
							
							<xsl:when test="@NOME-COMPLETO-DO-AUTOR">
								<xsl:value-of select="@NOME-COMPLETO-DO-AUTOR"/>
							</xsl:when>
							
							<!-- Na ausência do @NOME-COMPLETO-DO-AUTOR, utiliza o @NOME-PARA-CITACAO -->
							
							<xsl:when test="@NOME-PARA-CITACAO = upper-case(@NOME-PARA-CITACAO)">
								<xsl:call-template name="CamelCase">
									<xsl:with-param name="text">
										<xsl:value-of select="substring-before(@NOME-PARA-CITACAO,';')"/>
									</xsl:with-param>
								</xsl:call-template>
							</xsl:when>
							
							<xsl:when test="substring-before(@NOME-PARA-CITACAO,',') = upper-case(substring-before(@NOME-PARA-CITACAO,','))">
								<xsl:call-template name="CamelCase">
									<xsl:with-param name="text">
										<xsl:value-of select="@NOME-PARA-CITACAO"/>
									</xsl:with-param>
								</xsl:call-template>
							</xsl:when>
							
							<xsl:otherwise>
								<xsl:value-of select="@NOME-PARA-CITACAO"/>
							</xsl:otherwise>
						</xsl:choose>	
					</xsl:variable>
					
					<xsl:choose>
						
						<!-- Inverte corretamente os casos em que o nome termina com "Júnior" -->
						
						<xsl:when test="ends-with($authorName,'Júnior')">
							<xsl:value-of select="functx:substring-after-last(replace($authorName,' Júnior',''),' ')"/>
							<xsl:text> Júnior, </xsl:text>
							<xsl:value-of select="functx:substring-before-last(replace($authorName,' Júnior',''),' ')"/>
						</xsl:when>
						
						<!-- Inverte corretamente os casos em que o nome termina com "Junior" (sem acento) -->
						
						<xsl:when test="ends-with($authorName,'Junior')">
							<xsl:value-of select="functx:substring-after-last(replace($authorName,' Junior',''),' ')"/>
							<xsl:text> Júnior, </xsl:text>
							<xsl:value-of select="functx:substring-before-last(replace($authorName,' Junior',''),' ')"/>
						</xsl:when>
						
						<!-- Inverte corretamente os casos em que o nome termina com "Jr" -->
						
						<xsl:when test="ends-with($authorName,'Jr')">
							<xsl:value-of select="functx:substring-after-last(replace($authorName,' Jr',''),' ')"/>
							<xsl:text> Júnior, </xsl:text>
							<xsl:value-of select="functx:substring-before-last(replace($authorName,' Jr',''),' ')"/>
						</xsl:when>
						
						<!-- Inverte corretamente os casos em que o nome termina com "JR" -->
						
						<xsl:when test="ends-with($authorName,'JR')">
							<xsl:value-of select="functx:substring-after-last(replace($authorName,' JR',''),' ')"/>
							<xsl:text> Júnior, </xsl:text>
							<xsl:value-of select="functx:substring-before-last(replace($authorName,' JR',''),' ')"/>
						</xsl:when>
						
						<!-- Inverte corretamente os casos em que o nome termina com "Jr." -->
						
						<xsl:when test="ends-with($authorName,'Jr.')">
							<xsl:value-of select="functx:substring-after-last(replace($authorName,' Jr.',''),' ')"/>
							<xsl:text> Júnior, </xsl:text>
							<xsl:value-of select="functx:substring-before-last(replace($authorName,' Jr.',''),' ')"/>
						</xsl:when>
						
						<!-- Inverte corretamente os casos em que o nome termina com "JR." -->
						
						<xsl:when test="ends-with($authorName,'JR.')">
							<xsl:value-of select="functx:substring-after-last(replace($authorName,' JR.',''),' ')"/>
							<xsl:text> Júnior, </xsl:text>
							<xsl:value-of select="functx:substring-before-last(replace($authorName,' JR.',''),' ')"/>
						</xsl:when>
						
						<!-- Inverte corretamente os casos em que o nome termina com "Filho" -->
						
						<xsl:when test="ends-with($authorName,'Filho')">
							<xsl:value-of select="functx:substring-after-last(replace($authorName,' Filho',''),' ')"/>
							<xsl:text> Filho, </xsl:text>
							<xsl:value-of select="functx:substring-before-last(replace($authorName,' Filho',''),' ')"/>
						</xsl:when>
						
						<!-- Inverte corretamente os casos em que o nome termina com "Neto" -->
						
						<xsl:when test="ends-with($authorName,'Neto')">
							<xsl:value-of select="functx:substring-after-last(replace($authorName,' Neto',''),' ')"/>
							<xsl:text> Neto, </xsl:text>
							<xsl:value-of select="functx:substring-before-last(replace($authorName,' Neto',''),' ')"/>
						</xsl:when>
						
						<!-- Inverte corretamente os casos em que o nome termina com "Sobrinho" -->
								
						<xsl:when test="ends-with($authorName,'Sobrinho')">
							<xsl:value-of select="functx:substring-after-last(replace($authorName,' Sobrinho',''),' ')"/>
							<xsl:text> Sobrinho, </xsl:text>
							<xsl:value-of select="functx:substring-before-last(replace($authorName,' Sobrinho',''),' ')"/>
						</xsl:when>
								
						<!-- Não inverte o nome (para os casos em que o nome já consta invertido no Lattes) -->
						
						<xsl:when test="contains($authorName,',')">
							<xsl:value-of select="$authorName"/>
						</xsl:when>
						
						<!-- Inverte o nome completo, deixando "Sobrenome, Nome" -->
								
						<xsl:when test="$authorName != ''">
							<xsl:value-of select="functx:substring-after-last($authorName,' ')"/>
							<xsl:text>, </xsl:text>
							<xsl:value-of select="functx:substring-before-last($authorName,' ')"/>
						</xsl:when>
						
					</xsl:choose>
					
					<!-- Acrescenta " [UNESP]" [e o ID do Lattes] após o nome do autor dono do Lattes -->
					
					<xsl:if test="$autorLattes = @NOME-COMPLETO-DO-AUTOR">
						<xsl:text> [UNESP]</xsl:text>
						<!--  
						<xsl:text>[Lattes:</xsl:text>
						<xsl:value-of select="$autorLattesId"/>
						<xsl:text>]</xsl:text> -->
					</xsl:if>
					
					<!-- Acrescenta o ID do Lattes após o nome do autor 
					
					<xsl:if test="@NRO-ID-CNPQ != '' and @NRO-ID-CNPQ != $autorLattesId">
						<xsl:text> [Lattes:</xsl:text>
						<xsl:value-of select="@NRO-ID-CNPQ"/>
						<xsl:text>]</xsl:text>
					</xsl:if> -->
					
				</dcvalue>
			</xsl:for-each>
			
			<!-- dc.contributor.institution -->
			
			<dcvalue element="contributor" qualifier="institution">Universidade Estadual Paulista (UNESP)</dcvalue>
			
			<!-- dc.date.issued -->
			
			<dcvalue element="date" qualifier="issued">
				<xsl:value-of select="DADOS-BASICOS-DO-ARTIGO/@ANO-DO-ARTIGO"/>
			</dcvalue>
			
			<!-- dc.description.abstract -->
			
			<xsl:if test="INFORMACOES-ADICIONAIS/@DESCRICAO-INFORMACOES-ADICIONAIS">
				<dcvalue element="description" qualifier="abstract">
				
					<xsl:attribute name="language">
						<xsl:choose>
							<xsl:when test="DADOS-BASICOS-DO-ARTIGO/@IDIOMA='Alemão'">de</xsl:when>
							<xsl:when test="DADOS-BASICOS-DO-ARTIGO/@IDIOMA='Inglês'">en</xsl:when>
							<xsl:when test="DADOS-BASICOS-DO-ARTIGO/@IDIOMA='Francês'">fr</xsl:when>
							<xsl:when test="DADOS-BASICOS-DO-ARTIGO/@IDIOMA='Italiano'">it</xsl:when>
							<xsl:when test="DADOS-BASICOS-DO-ARTIGO/@IDIOMA='Português'">pt</xsl:when>
							<xsl:when test="DADOS-BASICOS-DO-ARTIGO/@IDIOMA='Espanhol'">es</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="DADOS-BASICOS-DO-ARTIGO/@IDIOMA" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				
					<xsl:variable name="resumo">
						<xsl:value-of select="replace(INFORMACOES-ADICIONAIS/@DESCRICAO-INFORMACOES-ADICIONAIS,'&#xa;','')"/>
					</xsl:variable>
				
					<xsl:choose>
						<xsl:when test="starts-with($resumo,'Resumo: ')">
							<xsl:value-of select="substring-after($resumo,'Resumo: ')"/>
						</xsl:when>
						<xsl:when test="starts-with($resumo,'Resumo ')">
							<xsl:value-of select="substring-after($resumo,'Resumo ')"/>
						</xsl:when>
						<xsl:when test="starts-with($resumo,'Resumo - ')">
							<xsl:value-of select="substring-after($resumo,'Resumo - ')"/>
						</xsl:when>
						<xsl:when test="starts-with($resumo,'Resumo')">
							<xsl:value-of select="substring-after($resumo,'Resumo')"/>
						</xsl:when>
						<xsl:when test="starts-with($resumo,'RESUMO: ')">
							<xsl:value-of select="substring-after($resumo,'RESUMO: ')"/>
						</xsl:when>
						<xsl:when test="starts-with($resumo,'RESUMO ')">
							<xsl:value-of select="substring-after($resumo,'RESUMO ')"/>
						</xsl:when>
						<xsl:when test="starts-with($resumo,'RESUMO - ')">
							<xsl:value-of select="substring-after($resumo,'RESUMO - ')"/>
						</xsl:when>
						<xsl:when test="starts-with($resumo,'RESUMO')">
							<xsl:value-of select="substring-after($resumo,'RESUMO')"/>
						</xsl:when>
						<xsl:when test="starts-with($resumo,'Abstract: ')">
							<xsl:value-of select="substring-after($resumo,'Abstract: ')"/>
						</xsl:when>
						<xsl:when test="starts-with($resumo,'Abstract ')">
							<xsl:value-of select="substring-after($resumo,'Abstract ')"/>
						</xsl:when>
						<xsl:when test="starts-with($resumo,'Abstract - ')">
							<xsl:value-of select="substring-after($resumo,'Abstract: - ')"/>
						</xsl:when>
						<xsl:when test="starts-with($resumo,'Abstract')">
							<xsl:value-of select="substring-after($resumo,'Abstract')"/>
						</xsl:when>
						<xsl:when test="starts-with($resumo,'ABSTRACT: ')">
							<xsl:value-of select="substring-after($resumo,'ABSTRACT: ')"/>
						</xsl:when>
						<xsl:when test="starts-with($resumo,'ABSTRACT ')">
							<xsl:value-of select="substring-after($resumo,'ABSTRACT ')"/>
						</xsl:when>
						<xsl:when test="starts-with($resumo,'ABSTRACT - ')">
							<xsl:value-of select="substring-after($resumo,'ABSTRACT: - ')"/>
						</xsl:when>
						<xsl:when test="starts-with($resumo,'ABSTRACT')">
							<xsl:value-of select="substring-after($resumo,'ABSTRACT')"/>
						</xsl:when>
						
						<xsl:otherwise>
							<xsl:value-of select="$resumo"/>
						</xsl:otherwise>
					</xsl:choose>
				
				</dcvalue>
			</xsl:if>
			
			<!-- dc.description.abstract[en] Informações adicionais em INGLÊS -->
			
			<dcvalue element="description" qualifier="abstract" language="en">

				<xsl:variable name="abstract">
					<xsl:value-of select="replace(INFORMACOES-ADICIONAIS/@DESCRICAO-INFORMACOES-ADICIONAIS-INGLES,'&#xa;','')"/>
				</xsl:variable>

				<xsl:choose>
					<xsl:when test="starts-with($abstract,'Abstract: ')">
						<xsl:value-of select="substring-after($abstract,'Abstract: ')"/>
					</xsl:when>
					<xsl:when test="starts-with($abstract,'Abstract ')">
						<xsl:value-of select="substring-after($abstract,'Abstract ')"/>
					</xsl:when>
					<xsl:when test="starts-with($abstract,'Abstract - ')">
						<xsl:value-of select="substring-after($abstract,'Abstract: - ')"/>
					</xsl:when>
					<xsl:when test="starts-with($abstract,'Abstract')">
						<xsl:value-of select="substring-after($abstract,'Abstract')"/>
					</xsl:when>
					<xsl:when test="starts-with($abstract,'ABSTRACT: ')">
						<xsl:value-of select="substring-after($abstract,'ABSTRACT: ')"/>
					</xsl:when>
					<xsl:when test="starts-with($abstract,'ABSTRACT ')">
						<xsl:value-of select="substring-after($abstract,'ABSTRACT ')"/>
					</xsl:when>
					<xsl:when test="starts-with($abstract,'ABSTRACT - ')">
						<xsl:value-of select="substring-after($abstract,'ABSTRACT: - ')"/>
					</xsl:when>
					<xsl:when test="starts-with($abstract,'ABSTRACT')">
						<xsl:value-of select="substring-after($abstract,'ABSTRACT')"/>
					</xsl:when>
					
					<xsl:otherwise>
						<xsl:value-of select="$abstract"/>
					</xsl:otherwise>
					
				</xsl:choose>
				
			</dcvalue>
			
			<!-- dc.description.affiliation -->
			
			<dcvalue element="description" qualifier="affiliation">
				<xsl:for-each select="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL[@CODIGO-INSTITUICAO-EMPRESA='033000000007']">
					
					<!-- Criar o valor a partir dos atributos do elemento ENDERECO-PROFISSIONAL -->
					
					<xsl:if test="@NOME-INSTITUICAO-EMPRESA != ''">
						<xsl:value-of select="@NOME-INSTITUICAO-EMPRESA"/>
					</xsl:if>
					<xsl:if test="@NOME-UNIDADE != ''">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="@NOME-UNIDADE"/>
					</xsl:if>
					<xsl:if test="@NOME-ORGAO != ''">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="@NOME-ORGAO"/>
					</xsl:if>
					<xsl:if test="@CIDADE != ''">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="@CIDADE"/>
					</xsl:if>
					<xsl:if test="@LOGRADOURO-COMPLEMENTO != ''">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="@LOGRADOURO-COMPLEMENTO"/>
					</xsl:if>
					<xsl:if test="@BAIRRO != ''">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="@BAIRRO"/>
					</xsl:if>
					<xsl:if test="@CEP != ''">
						<xsl:text>, CEP </xsl:text>
						<xsl:value-of select="@CEP"/>
					</xsl:if>
					<xsl:if test="@UF != ''">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="@UF"/>
					</xsl:if>
					<xsl:if test="@PAIS != ''">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="@PAIS"/>
					</xsl:if>
				</xsl:for-each>
				
				<!-- Adiciona "||" para os casos em que há mais de um autor no artigo -->
				
				<xsl:if test="count(AUTORES) != 1">
					<xsl:text>||</xsl:text>
				</xsl:if>
				
			</dcvalue>
			
			<!-- dc.description.affiliationUnesp -->
			
			<dcvalue element="description" qualifier="affiliationUnesp">
				<xsl:for-each select="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL[@CODIGO-INSTITUICAO-EMPRESA='033000000007']">
					
					<!-- Criar o valor a partir dos atributos do elemento ENDERECO-PROFISSIONAL -->
					
					<xsl:if test="@NOME-INSTITUICAO-EMPRESA != ''">
						<xsl:value-of select="@NOME-INSTITUICAO-EMPRESA"/>
					</xsl:if>
					<xsl:if test="@NOME-UNIDADE != ''">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="@NOME-UNIDADE"/>
					</xsl:if>
					<xsl:if test="@NOME-ORGAO != ''">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="@NOME-ORGAO"/>
					</xsl:if>
					<xsl:if test="@CIDADE != ''">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="@CIDADE"/>
					</xsl:if>
					<xsl:if test="@LOGRADOURO-COMPLEMENTO != ''">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="@LOGRADOURO-COMPLEMENTO"/>
					</xsl:if>
					<xsl:if test="@BAIRRO != ''">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="@BAIRRO"/>
					</xsl:if>
					<xsl:if test="@CEP != ''">
						<xsl:text>, CEP </xsl:text>
						<xsl:value-of select="@CEP"/>
					</xsl:if>
					<xsl:if test="@UF != ''">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="@UF"/>
					</xsl:if>
					<xsl:if test="@PAIS != ''">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="@PAIS"/>
					</xsl:if>
				</xsl:for-each>
			</dcvalue>
			
			<!-- dc.description.extent -->
			
			<dcvalue element="description" qualifier="extent">
				<xsl:value-of select="DETALHAMENTO-DO-ARTIGO/@PAGINA-INICIAL"/>
				<xsl:if test="DETALHAMENTO-DO-ARTIGO/@PAGINA-FINAL != ''">
					<xsl:text>-</xsl:text>
					<xsl:value-of select="DETALHAMENTO-DO-ARTIGO/@PAGINA-FINAL"/>
				</xsl:if>
			</dcvalue>
			
			<!-- dc.identifier -->
			
			<dcvalue element="identifier">
				<xsl:choose>
					<xsl:when test="DADOS-BASICOS-DO-ARTIGO/@DOI != ''">
						<xsl:text>http://dx.doi.org/</xsl:text>
						<xsl:value-of select="DADOS-BASICOS-DO-ARTIGO/@DOI"/>
					</xsl:when>
					<xsl:when test="starts-with(DADOS-BASICOS-DO-ARTIGO/@HOME-PAGE-DO-TRABALHO,'doi') or
						starts-with(DADOS-BASICOS-DO-ARTIGO/@HOME-PAGE-DO-TRABALHO,'DOI') or 
						starts-with(DADOS-BASICOS-DO-ARTIGO/@HOME-PAGE-DO-TRABALHO,'10.')">
						<xsl:value-of select="replace(DADOS-BASICOS-DO-ARTIGO/@HOME-PAGE-DO-TRABALHO,substring-before(DADOS-BASICOS-DO-ARTIGO/@HOME-PAGE-DO-TRABALHO,'10.'),'http://dx.doi.org/10.')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="replace(replace(DADOS-BASICOS-DO-ARTIGO/@HOME-PAGE-DO-TRABALHO,'\[',''),'\]','')"/>
					</xsl:otherwise>
				</xsl:choose>
			</dcvalue>
			
			<!-- dc.identifier.scielo -->
			
			<xsl:if test="contains(DADOS-BASICOS-DO-ARTIGO/@HOME-PAGE-DO-TRABALHO,'scielo') and contains(DADOS-BASICOS-DO-ARTIGO/@HOME-PAGE-DO-TRABALHO,'pid=S')">
				<dcvalue element="identifier" qualifier="scielo">
					<xsl:value-of select="substring-before(substring-after(DADOS-BASICOS-DO-ARTIGO/@HOME-PAGE-DO-TRABALHO,'pid='),'&amp;')"/>
				</dcvalue>
			</xsl:if>
			
			<!-- dc.identifier.citation -->
			
			<dcvalue element="identifier" qualifier="citation">
				<xsl:choose>
					<xsl:when test="contains(DETALHAMENTO-DO-ARTIGO/@TITULO-DO-PERIODICO-OU-REVISTA,' (') and ends-with(DETALHAMENTO-DO-ARTIGO/@TITULO-DO-PERIODICO-OU-REVISTA,')')">
						<xsl:value-of select="substring-before(DETALHAMENTO-DO-ARTIGO/@TITULO-DO-PERIODICO-OU-REVISTA,' (')"/>
					</xsl:when>
					<xsl:when test="DETALHAMENTO-DO-ARTIGO/@TITULO-DO-PERIODICO-OU-REVISTA = upper-case(DETALHAMENTO-DO-ARTIGO/@TITULO-DO-PERIODICO-OU-REVISTA)">
						<xsl:call-template name="CamelCase">
							<xsl:with-param name="text">
								<xsl:value-of select="DETALHAMENTO-DO-ARTIGO/@TITULO-DO-PERIODICO-OU-REVISTA"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="DETALHAMENTO-DO-ARTIGO/@TITULO-DO-PERIODICO-OU-REVISTA"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="DETALHAMENTO-DO-ARTIGO/@LOCAL-DE-PUBLICACAO != ''">
					<xsl:text>, </xsl:text>
					<xsl:value-of select="DETALHAMENTO-DO-ARTIGO/@LOCAL-DE-PUBLICACAO"/>
				</xsl:if>
				<xsl:if test="DETALHAMENTO-DO-ARTIGO/@VOLUME != ''">
					<xsl:text>, v. </xsl:text>
					<xsl:value-of select="DETALHAMENTO-DO-ARTIGO/@VOLUME"/>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="DETALHAMENTO-DO-ARTIGO/@FASCICULO != ''">
						<xsl:text>, n. </xsl:text>
						<xsl:value-of select="DETALHAMENTO-DO-ARTIGO/@FASCICULO"/>
					</xsl:when>
					<xsl:when test="DETALHAMENTO-DO-ARTIGO/@SERIE != ''">
						<xsl:text>, n. </xsl:text>
						<xsl:value-of select="DETALHAMENTO-DO-ARTIGO/@SERIE"/>
					</xsl:when>
				</xsl:choose>
				<xsl:if test="DETALHAMENTO-DO-ARTIGO/@PAGINA-INICIAL != ''">
					<xsl:text>, p. </xsl:text>
					<xsl:value-of select="DETALHAMENTO-DO-ARTIGO/@PAGINA-INICIAL"/>
				</xsl:if>
				<xsl:if test="DETALHAMENTO-DO-ARTIGO/@PAGINA-FINAL != ''">
					<xsl:text>-</xsl:text>
					<xsl:value-of select="DETALHAMENTO-DO-ARTIGO/@PAGINA-FINAL"/>
				</xsl:if>
				<xsl:if test="DADOS-BASICOS-DO-ARTIGO/@ANO-DO-ARTIGO != ''">
					<xsl:text>, </xsl:text>
					<xsl:value-of select="DADOS-BASICOS-DO-ARTIGO/@ANO-DO-ARTIGO"/>
				</xsl:if>
				<xsl:text>.</xsl:text>
			</dcvalue>
			
			<!-- dc.identifier.doi -->
			
			<dcvalue element="identifier" qualifier="doi">
				<xsl:choose>
					<xsl:when test="DADOS-BASICOS-DO-ARTIGO/@DOI != ''">
						<xsl:value-of select="DADOS-BASICOS-DO-ARTIGO/@DOI"/>		
					</xsl:when>
					<xsl:when test="starts-with(INFORMACOES-ADICIONAIS/@DESCRICAO-INFORMACOES-ADICIONAIS,'DOI') or 
						starts-with(INFORMACOES-ADICIONAIS/@DESCRICAO-INFORMACOES-ADICIONAIS,'doi')">
						<xsl:value-of select="INFORMACOES-ADICIONAIS/@DESCRICAO-INFORMACOES-ADICIONAIS"/>
					</xsl:when>
				</xsl:choose>
			</dcvalue>
			
			<!-- dc.identifier.issn -->
			
			<dcvalue element="identifier" qualifier="issn">
				<xsl:if test="DETALHAMENTO-DO-ARTIGO/@ISSN != ''">
					<xsl:value-of select="concat(substring(DETALHAMENTO-DO-ARTIGO/@ISSN,1,4),'-',substring(DETALHAMENTO-DO-ARTIGO/@ISSN,5,4))"/>
				</xsl:if>
			</dcvalue>
			
			<!-- dc.identifier.file -->
			
			<dcvalue element="identifier" qualifier="file">
				<xsl:text>ISSN</xsl:text>
				<xsl:value-of select="concat(substring(DETALHAMENTO-DO-ARTIGO/@ISSN,1,4),'-',substring(DETALHAMENTO-DO-ARTIGO/@ISSN,5,4))"/>
				<xsl:text>-</xsl:text>
				<xsl:value-of select="DADOS-BASICOS-DO-ARTIGO/@ANO-DO-ARTIGO"/>
				<xsl:text>-</xsl:text>
				<xsl:choose>
					<xsl:when test="string-length(DETALHAMENTO-DO-ARTIGO/@VOLUME) = 1">
						<xsl:text>0</xsl:text>
						<xsl:value-of select="DETALHAMENTO-DO-ARTIGO/@VOLUME"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="DETALHAMENTO-DO-ARTIGO/@VOLUME"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>-</xsl:text>
				<xsl:choose>
					<xsl:when test="string-length(DETALHAMENTO-DO-ARTIGO/@FASCICULO) = 1">
						<xsl:text>0</xsl:text>
						<xsl:value-of select="DETALHAMENTO-DO-ARTIGO/@FASCICULO"/>
					</xsl:when>
					<xsl:when test="string-length(DETALHAMENTO-DO-ARTIGO/@FASCICULO) &gt; 1">
						<xsl:value-of select="DETALHAMENTO-DO-ARTIGO/@FASCICULO"/>
					</xsl:when>
					<xsl:when test="string-length(DETALHAMENTO-DO-ARTIGO/@SERIE) = 1">
						<xsl:text>0</xsl:text>
						<xsl:value-of select="DETALHAMENTO-DO-ARTIGO/@SERIE"/>
					</xsl:when>
					<xsl:when test="string-length(DETALHAMENTO-DO-ARTIGO/@SERIE) &gt; 1">
						<xsl:value-of select="DETALHAMENTO-DO-ARTIGO/@SERIE"/>
					</xsl:when>
				</xsl:choose>
				<xsl:text>-</xsl:text>
				<xsl:choose>
					<xsl:when test="string-length(DETALHAMENTO-DO-ARTIGO/@PAGINA-INICIAL) = 1">
						<xsl:text>0</xsl:text>
						<xsl:value-of select="DETALHAMENTO-DO-ARTIGO/@PAGINA-INICIAL"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="DETALHAMENTO-DO-ARTIGO/@PAGINA-INICIAL"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="DETALHAMENTO-DO-ARTIGO/@PAGINA-FINAL != ''">
					<xsl:text>-</xsl:text>	
				</xsl:if>
				<xsl:choose>
					<xsl:when test="string-length(DETALHAMENTO-DO-ARTIGO/@PAGINA-FINAL) = 1">
						<xsl:text>0</xsl:text>
						<xsl:value-of select="DETALHAMENTO-DO-ARTIGO/@PAGINA-FINAL"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="DETALHAMENTO-DO-ARTIGO/@PAGINA-FINAL"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>.pdf</xsl:text>
			</dcvalue>
				
			<!-- dc.identifier.lattes -->
			
			<dcvalue element="identifier" qualifier="lattes">
				<xsl:value-of select="$autorLattesId"/>
			</dcvalue>
			
			<xsl:for-each select="AUTORES/@NRO-ID-CNPQ">
				<xsl:if test=". != ''">
					<dcvalue element="identifier" qualifier="lattes">
						<xsl:value-of select="."/>
					</dcvalue>
				</xsl:if>
			</xsl:for-each>
			
			<!-- dc.language.iso -->
			
			<dcvalue element="language" qualifier="iso">
				<xsl:choose>
					<xsl:when test="DADOS-BASICOS-DO-ARTIGO/@IDIOMA='Alemão'">deu</xsl:when>
					<xsl:when test="DADOS-BASICOS-DO-ARTIGO/@IDIOMA='Inglês'">eng</xsl:when>
					<xsl:when test="DADOS-BASICOS-DO-ARTIGO/@IDIOMA='Francês'">fra</xsl:when>
					<xsl:when test="DADOS-BASICOS-DO-ARTIGO/@IDIOMA='Italiano'">ita</xsl:when>
					<xsl:when test="DADOS-BASICOS-DO-ARTIGO/@IDIOMA='Português'">por</xsl:when>
					<xsl:when test="DADOS-BASICOS-DO-ARTIGO/@IDIOMA='Espanhol'">spa</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="DADOS-BASICOS-DO-ARTIGO/@IDIOMA" />
					</xsl:otherwise>
				</xsl:choose>
			</dcvalue>
			
			<!-- dc.relation.ispartof -->
			
			<dcvalue element="relation" qualifier="ispartof">
				<xsl:choose>
					<xsl:when test="contains(DETALHAMENTO-DO-ARTIGO/@TITULO-DO-PERIODICO-OU-REVISTA,' (') and ends-with(DETALHAMENTO-DO-ARTIGO/@TITULO-DO-PERIODICO-OU-REVISTA,')')">
						<xsl:value-of select="substring-before(DETALHAMENTO-DO-ARTIGO/@TITULO-DO-PERIODICO-OU-REVISTA,' (')"/>
					</xsl:when>
					<xsl:when test="DETALHAMENTO-DO-ARTIGO/@TITULO-DO-PERIODICO-OU-REVISTA = upper-case(DETALHAMENTO-DO-ARTIGO/@TITULO-DO-PERIODICO-OU-REVISTA)">
						<xsl:call-template name="CamelCase">
							<xsl:with-param name="text">
								<xsl:value-of select="DETALHAMENTO-DO-ARTIGO/@TITULO-DO-PERIODICO-OU-REVISTA"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="DETALHAMENTO-DO-ARTIGO/@TITULO-DO-PERIODICO-OU-REVISTA"/>
					</xsl:otherwise>
				</xsl:choose>
			</dcvalue>
			
			<!-- dc.source -->
			
			<dcvalue element="source">Currículo Lattes</dcvalue>
			
			<!-- dc.subject -->
			
			<xsl:for-each select="PALAVRAS-CHAVE/@*">
				<dcvalue element="subject">
					<xsl:attribute name="language">
						<xsl:choose>
							<xsl:when test="ancestor::node()[2]/DADOS-BASICOS-DO-ARTIGO/@IDIOMA='Alemão'">de</xsl:when>
							<xsl:when test="ancestor::node()[2]/DADOS-BASICOS-DO-ARTIGO/@IDIOMA='Inglês'">en</xsl:when>
							<xsl:when test="ancestor::node()[2]/DADOS-BASICOS-DO-ARTIGO/@IDIOMA='Francês'">fr</xsl:when>
							<xsl:when test="ancestor::node()[2]/DADOS-BASICOS-DO-ARTIGO/@IDIOMA='Italiano'">it</xsl:when>
							<xsl:when test="ancestor::node()[2]/DADOS-BASICOS-DO-ARTIGO/@IDIOMA='Português'">pt</xsl:when>
							<xsl:when test="ancestor::node()[2]/DADOS-BASICOS-DO-ARTIGO/@IDIOMA='Espanhol'">es</xsl:when>
						</xsl:choose>
					</xsl:attribute>
					<xsl:value-of select="."/>
				</dcvalue>
			</xsl:for-each>
			
			<!-- 
			<dcvalue element="subject" language="pt">
				<xsl:value-of select="PALAVRAS-CHAVE/@PALAVRA-CHAVE-1"/>
			</dcvalue>
			
			<dcvalue element="subject" language="pt">
				<xsl:value-of select="PALAVRAS-CHAVE/@PALAVRA-CHAVE-2"/>
			</dcvalue>
			
			<dcvalue element="subject" language="pt">
				<xsl:value-of select="PALAVRAS-CHAVE/@PALAVRA-CHAVE-3"/>
			</dcvalue>
			
			<dcvalue element="subject" language="pt">
				<xsl:value-of select="PALAVRAS-CHAVE/@PALAVRA-CHAVE-4"/>
			</dcvalue>
			
			<dcvalue element="subject" language="pt">
				<xsl:value-of select="PALAVRAS-CHAVE/@PALAVRA-CHAVE-5"/>
			</dcvalue>
			
			<dcvalue element="subject" language="pt">
				<xsl:value-of select="PALAVRAS-CHAVE/@PALAVRA-CHAVE-6"/>
			</dcvalue>
			 -->
			
			<!-- dc.title -->
			
			<dcvalue element="title">
				<xsl:attribute name="language">
					<xsl:choose>
						<xsl:when test="DADOS-BASICOS-DO-ARTIGO/@IDIOMA='Alemão'">de</xsl:when>
						<xsl:when test="DADOS-BASICOS-DO-ARTIGO/@IDIOMA='Inglês'">en</xsl:when>
						<xsl:when test="DADOS-BASICOS-DO-ARTIGO/@IDIOMA='Francês'">fr</xsl:when>
						<xsl:when test="DADOS-BASICOS-DO-ARTIGO/@IDIOMA='Italiano'">it</xsl:when>
						<xsl:when test="DADOS-BASICOS-DO-ARTIGO/@IDIOMA='Português'">pt</xsl:when>
						<xsl:when test="DADOS-BASICOS-DO-ARTIGO/@IDIOMA='Espanhol'">es</xsl:when>
					</xsl:choose>
				</xsl:attribute>
				<xsl:value-of select="replace(DADOS-BASICOS-DO-ARTIGO/@TITULO-DO-ARTIGO,'&#xa;','')"/>
			</dcvalue>
			
			<!-- dc.title.alternative -->
			
			<xsl:if test="DADOS-BASICOS-DO-ARTIGO/@TITULO-DO-ARTIGO != DADOS-BASICOS-DO-ARTIGO/@TITULO-DO-ARTIGO-INGLES">
				<dcvalue element="title" qualifier="alternative" language="en">
					<xsl:value-of select="replace(DADOS-BASICOS-DO-ARTIGO/@TITULO-DO-ARTIGO-INGLES,'&#xa;','')"/>
				</dcvalue>
			</xsl:if>
			
			<!-- dc.type -->
			
			<dcvalue element="type">
				<xsl:text>Artigo</xsl:text>
			</dcvalue>
			
			<!-- unesp.campus -->
			
			<dcvalue element="campus">
				<xsl:choose>
					
					<!-- Busca pelo nome da unidade (DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO e DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE) -->
					
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Faculdade de Medicicna Veterinária de Araçatuba'">Faculdade de Medicina Veterinária (FMVA)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Faculdade de Odontologia de Araçatuba'">Faculdade de Odontologia (FOA)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Faculdade de Ciências e Letras de Araraquara'">Faculdade de Ciências e Letras (FCLAR)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Faculdade de Ciências Farmacêuticas de Araraquara'">Faculdade de Ciências Farmacêuticas (FCFAR)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Faculdade de Odontologia de Araraquara'">Faculdade de Odontologia (FOAR)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Instituto de Química de Araraquara'">Instituto de Química (IQ)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Faculdade de Ciências e Letras de Assis'">Faculdade de Ciências e Letras (FCLAS)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Faculdade de Arquitetura Artes e Comunicação de Bauru'">Faculdade de Arquitetura, Artes e Comunicação (FAAC)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Faculdade de Ciências de Bauru'">Faculdade de Ciências (FC)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Faculdade de Engenharia de Bauru'">Faculdade de Engenharia (FEB)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Instituto de Pesquisas Meteorológicas - Campus Bauru'">Instituto de Pesquisas Meteorológicas (IPMet)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Faculdade de Ciências Agronômicas de Botucatu'">Faculdade de Ciências Agronômicas (FCA)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Faculdade de Medicina de Botucatu'">Faculdade de Medicina (FMB)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Faculdade de Medicina Veterinária e Zootecnia de Botucatu'">Faculdade de Medicina Veterinária e Zootecnia (FMVZ)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Campus Experimental de Dracena'">Câmpus Experimental de Dracena</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'UNESP - Campus de Franca'">Faculdade de Ciências Humanas e Sociais (FCHS)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Faculdade de História, Direito e Serviço Social de Franca'">Faculdade de Ciências Humanas e Sociais (FCHS)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Faculdade de Engenharia de Guaratinguetá'">Faculdade de Engenharia (FEG)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Faculdade de Engenharia de Ilha Solteira'">Faculdade de Engenharia (FEIS)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Campus Experimental de Itapeva'">Câmpus Experimental de Itapeva</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Faculdade de Ciências Agrárias e Veterinárias de Jaboticabal'">Faculdade de Ciências Agrárias e Veterinárias (FCAV)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Faculdade de Filosofia e Ciências - Campus de Marília'">Faculdade de Filosofia e Ciências (FFC)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Unidade Diferenciada de Ourinhos'">Câmpus Experimental de Ourinhos</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Campus Presidente Prudente'">Faculdade de Ciências e Tecnologia (FCT)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Campus Experimental de Registro'">Câmpus Experimental de Registro</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Instituto de Biociências de Rio Claro'">Instituto de Biociências (IBRC)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Instituto de Geociências e Ciências Exatas de Rio Claro'">Instituto de Geociências e Ciências Exatas (IGCE)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Campus Experimental Rosana'">Câmpus Experimental de Rosana</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Instituto de Biociências Letras e Ciências Exatas de São José do Rio Preto'">Instituto de Biociências, Letras e Ciências Exatas (IBILCE)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Instituto de Ciência e Tecnologia - Campus de São José dos Campos'">Instituto de Ciência e Tecnologia (ICT)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Instituto de Artes'">Instituto de Artes (IA)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Instituto de Física Teórica'">Instituto de Física Teórica (IFT)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Campus do Litoral Paulista - Unidade São Vicente'">Câmpus Experimental do Litoral Paulista</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Campus Experimental de Sorocaba'">Câmpus Experimental de Sorocaba</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO = 'Campus Experimental de Tupã'">Câmpus Experimental de Tupã</xsl:when>
					
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Faculdade de Medicicna Veterinária de Araçatuba'">Faculdade de Medicina Veterinária (FMVA)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Faculdade de Odontologia de Araçatuba'">Faculdade de Odontologia (FOA)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Faculdade de Ciências e Letras de Araraquara'">Faculdade de Ciências e Letras (FCLAR)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Faculdade de Ciências Farmacêuticas de Araraquara'">Faculdade de Ciências Farmacêuticas (FCFAR)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Faculdade de Odontologia de Araraquara'">Faculdade de Odontologia (FOAR)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Instituto de Química de Araraquara'">Instituto de Química (IQ)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Faculdade de Ciências e Letras de Assis'">Faculdade de Ciências e Letras (FCLAS)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Faculdade de Arquitetura Artes e Comunicação de Bauru'">Faculdade de Arquitetura, Artes e Comunicação (FAAC)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Faculdade de Ciências de Bauru'">Faculdade de Ciências (FC)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Faculdade de Engenharia de Bauru'">Faculdade de Engenharia (FEB)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Instituto de Pesquisas Meteorológicas - Campus Bauru'">Instituto de Pesquisas Meteorológicas (IPMet)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Faculdade de Ciências Agronômicas de Botucatu'">Faculdade de Ciências Agronômicas (FCA)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Faculdade de Medicina de Botucatu'">Faculdade de Medicina (FMB)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Faculdade de Medicina Veterinária e Zootecnia de Botucatu'">Faculdade de Medicina Veterinária e Zootecnia (FMVZ)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Campus Experimental de Dracena'">Câmpus Experimental de Dracena</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'UNESP - Campus de Franca'">Faculdade de Ciências Humanas e Sociais (FCHS)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Faculdade de História, Direito e Serviço Social de Franca'">Faculdade de Ciências Humanas e Sociais (FCHS)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Faculdade de Engenharia de Guaratinguetá'">Faculdade de Engenharia (FEG)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Faculdade de Engenharia de Ilha Solteira'">Faculdade de Engenharia (FEIS)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Campus Experimental de Itapeva'">Câmpus Experimental de Itapeva</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Faculdade de Ciências Agrárias e Veterinárias de Jaboticabal'">Faculdade de Ciências Agrárias e Veterinárias (FCAV)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Faculdade de Filosofia e Ciências - Campus de Marília'">Faculdade de Filosofia e Ciências (FFC)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Unidade Diferenciada de Ourinhos'">Câmpus Experimental de Ourinhos</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Campus Presidente Prudente'">Faculdade de Ciências e Tecnologia (FCT)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Campus Experimental de Registro'">Câmpus Experimental de Registro</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Instituto de Biociências de Rio Claro'">Instituto de Biociências (IBRC)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Instituto de Geociências e Ciências Exatas de Rio Claro'">Instituto de Geociências e Ciências Exatas (IGCE)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Campus Experimental Rosana'">Câmpus Experimental de Rosana</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Instituto de Biociências Letras e Ciências Exatas de São José do Rio Preto'">Instituto de Biociências, Letras e Ciências Exatas (IBILCE)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Instituto de Ciência e Tecnologia - Campus de São José dos Campos'">Instituto de Ciência e Tecnologia (ICT)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Instituto de Artes'">Instituto de Artes (IA)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Instituto de Física Teórica'">Instituto de Física Teórica (IFT)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Campus do Litoral Paulista - Unidade São Vicente'">Câmpus Experimental do Litoral Paulista</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Campus Experimental de Sorocaba'">Câmpus Experimental de Sorocaba</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE = 'Campus Experimental de Tupã'">Câmpus Experimental de Tupã</xsl:when>
					
					<!-- Busca pela cidade (DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@CIDADE) -->
					<!-- Incluir apenas as cidades em que há uma única unidade da UNESP -->
					
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@CIDADE = 'Assis'">Faculdade de Ciências e Letras (FCLAS)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@CIDADE = 'Dracena'">Câmpus Experimental de Dracena</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@CIDADE = 'Franca'">Faculdade de Ciências Humanas e Sociais (FCHS)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@CIDADE = 'Guaratinguetá'">Faculdade de Engenharia (FEG)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@CIDADE = 'Guaratingueta'">Faculdade de Engenharia (FEG)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@CIDADE = 'Ilha Solteira'">Faculdade de Engenharia (FEIS)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@CIDADE = 'Itapeva'">Câmpus Experimental de Itapeva</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@CIDADE = 'Jaboticabal'">Faculdade de Ciências Agrárias e Veterinárias (FCAV)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@CIDADE = 'Marília'">Faculdade de Filosofia e Ciências (FFC)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@CIDADE = 'Marilia'">Faculdade de Filosofia e Ciências (FFC)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@CIDADE = 'Ourinhos'">Câmpus Experimental de Ourinhos</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@CIDADE = 'Presidente Prudente'">Faculdade de Ciências e Tecnologia (FCT)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@CIDADE = 'Registro'">Câmpus Experimental de Registro</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@CIDADE = 'Rio Claro'">Instituto de Biociências (IBRC)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@CIDADE = 'Rosana'">Câmpus Experimental de Rosana</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@CIDADE = 'São José do Rio Preto'">Instituto de Biociências, Letras e Ciências Exatas (IBILCE)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@CIDADE = 'Sao Jose do Rio Preto'">Instituto de Biociências, Letras e Ciências Exatas (IBILCE)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@CIDADE = 'São José dos Campos'">Instituto de Ciência e Tecnologia (ICT)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@CIDADE = 'Sao Jose dos Campos'">Instituto de Ciência e Tecnologia (ICT)</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@CIDADE = 'São Vicente'">Câmpus Experimental do Litoral Paulista</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@CIDADE = 'Sao Vicente'">Câmpus Experimental do Litoral Paulista</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@CIDADE = 'Sorocaba'">Câmpus Experimental de Sorocaba</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@CIDADE = 'Tupã'">Câmpus Experimental de Tupã</xsl:when>
					<xsl:when test="ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@CIDADE = 'Tupa'">Câmpus Experimental de Tupã</xsl:when>
				</xsl:choose>
			</dcvalue>
			
			<!-- unesp.department -->
			
			<dcvalue element="department">
				<xsl:if test="starts-with(ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO,'Departamento de')">
					<xsl:value-of select="substring-after(ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-ORGAO,'Departamento de ')"/>
				</xsl:if>
				<xsl:if test="starts-with(ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE,'Departamento de')">
					<xsl:value-of select="substring-after(ancestor::node()[3]/DADOS-GERAIS/ENDERECO/ENDERECO-PROFISSIONAL/@NOME-UNIDADE,'Departamento de ')"/>
				</xsl:if>
			</dcvalue>
			
		</dublin_core>
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
	
</xsl:stylesheet>
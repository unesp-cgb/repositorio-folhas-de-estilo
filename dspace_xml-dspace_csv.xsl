<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <!--
    Folha de estilo XSLT 2.0 utilizada para a conversão de arquivos Dublin Core (XML DSpace) em arquivos CSV para importação no DSpace 
    Elaborada por Fabrício Silva Assumpção (fabricio@reitoria.unesp.br)
    Última atualização: 2015-03-09
    
    Observações:
    1) Alguns metadados obsoletos foram mantidos no interior das regras para garantir a compatibilidade com as folhas de estilo mais antigas.
    
    -->
    
    <xsl:output method="text" indent="no" encoding="UTF-8" />
    
    <xsl:template match="/">
        
        <!-- Cabeçalho do arquivo CSV -->
        
        <xsl:text>"id","collection","dc.contributor.advisor[]","dc.contributor.author[]","dc.contributor.institution[]","dc.date.issued[]","dc.description.abstract[]","dc.description.abstract[en]","dc.description.abstract[es]","dc.description.abstract[fr]","dc.description.abstract[pt]","dc.description.affiliation[]","dc.description.affiliationUnesp[]","dc.description.sponsorship[]","dc.description.sponsorshipId[]","dc.format.extent[]","dc.identifier[]","dc.identifier.aleph[]","dc.identifier.capes[]","dc.identifier.citation[]","dc.identifier.doi[]","dc.identifier.file[]","dc.identifier.isbn[]","dc.identifier.issn[]","dc.identifier.lattes[]","dc.identifier.scielo[]","dc.identifier.scopus[]","dc.identifier.wos[]","dc.language.iso[]","dc.publisher[]","dc.relation.ispartof[]","dc.rights.accessRights[]","dc.source[]","dc.subject[]","dc.subject[en]","dc.subject[pt]","dc.title[]","dc.title[en]","dc.title[es]","dc.title[fr]","dc.title[pt]","dc.title.alternative[]","dc.title.alternative[en]","dc.title.alternative[es]","dc.title.alternative[fr]","dc.title.alternative[pt]","dc.type[]","dcterms.license[]","dcterms.rightsHolder[]","unesp.campus[pt]","unesp.department[pt]","unesp.graduateProgram[pt]","unesp.knowledgeArea[pt]","unesp.researchArea[pt]","unesp.undergraduate[pt]"</xsl:text>
        <xsl:text>&#xa;</xsl:text>
        
        <xsl:for-each select="records/dublin_core">
            <xsl:call-template name="csvRecord" />
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:template name="csvRecord">
        
        <!-- id -->
        
        <!-- Na importação do CSV, os registros que estão com "+" na primeira coluna receberão um ID novo no DSpace -->

        <xsl:text>+</xsl:text>
        
        <!-- handle da coleção -->
        
        <!-- Substituir pelo handle da coleção para qual vão os registros. Exemplo: unesp/123456 -->
        
        <xsl:text>,</xsl:text>
        <xsl:choose>
            <xsl:when test="collection">
                <xsl:value-of select="string-join(distinct-values(collection),'||')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>collection</xsl:text>
            </xsl:otherwise>
        </xsl:choose>

        <!-- dc.contributor.advisor -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="string-join(distinct-values(dcvalue[@element='contributor' and @qualifier='advisor']),'||')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.contributor.author -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="string-join(distinct-values(dcvalue[@element='contributor' and @qualifier='author']),'||')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.contributor.institution -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="replace(string-join(distinct-values(dcvalue[@element='contributor' and @qualifier='institution']),'||'),'&quot;','')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.date.issued -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="dcvalue[@element='date' and @qualifier='issued']" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.description.abstract -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="replace(string-join(dcvalue[@element='description' and @qualifier='abstract' and not(@language)],'||'),'&quot;','')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.description.abstract[en] -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="replace(string-join(dcvalue[@element='description' and @qualifier='abstract' and @language='en'],'||'),'&quot;','')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.description.abstract[es] -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="replace(string-join(dcvalue[@element='description' and @qualifier='abstract' and @language='es'],'||'),'&quot;','')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.description.abstract[fr] -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="replace(string-join(dcvalue[@element='description' and @qualifier='abstract' and @language='fr'],'||'),'&quot;','')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.description.abstract[pt] -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="replace(string-join(dcvalue[@element='description' and @qualifier='abstract' and @language='pt'],'||'),'&quot;','')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.description.affiliation -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="replace(string-join(distinct-values(dcvalue[@element='description' and @qualifier='affiliation']),'||'),'&quot;','')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.description.affiliationUnesp -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="replace(string-join(distinct-values(dcvalue[@element='description' and @qualifier='affiliationUnesp']),'||'),'&quot;','')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.description.sponsorship -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="replace(string-join(distinct-values(dcvalue[@element='description' and @qualifier='sponsorship']),'||'),'&quot;','')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.description.sponsorshipId -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="replace(string-join(distinct-values(dcvalue[@element='description' and @qualifier='sponsorshipId']),'||'),'&quot;','')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.format.extent e dc.description.extent [OBSOLETO] -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="dcvalue[@element='format' and @qualifier='extent']" />
        <xsl:value-of select="dcvalue[@element='description' and @qualifier='extent']" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.identifier -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="dcvalue[@element='identifier' and not(@qualifier)]" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.identifier.aleph -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="dcvalue[@element='identifier' and @qualifier='aleph']" />
        <xsl:text>&quot;</xsl:text>

        <!-- dc.identifier.capes -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="dcvalue[@element='identifier' and @qualifier='capes']" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.identifier.citation e dc.bibliographicCitation [OBSOLETO] -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="replace(dcvalue[@element='identifier' and @qualifier='citation'],'&quot;','')" />
        <xsl:value-of select="replace(dcvalue[@element='bibliographicCitation'],'&quot;','')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.identifier.doi -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="dcvalue[@element='identifier' and @qualifier='doi']" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.identifier.file -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="string-join(distinct-values(dcvalue[@element='identifier' and @qualifier='file']),'||')" />
        <xsl:text>&quot;</xsl:text>
        
    	<!-- dc.identifier.isbn -->
    	
    	<xsl:text>,&quot;</xsl:text>
    	<xsl:value-of select="string-join(distinct-values(dcvalue[@element='identifier' and @qualifier='isbn']),'||')" />
    	<xsl:text>&quot;</xsl:text>
    	
        <!-- dc.identifier.issn -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="string-join(distinct-values(dcvalue[@element='identifier' and @qualifier='issn']),'||')" />
        <xsl:text>&quot;</xsl:text>

    	<!-- dc.identifier.lattes -->
    	
    	<xsl:text>,&quot;</xsl:text>
    	<xsl:value-of select="string-join(distinct-values(dcvalue[@element='identifier' and @qualifier='lattes']),'||')" />
    	<xsl:text>&quot;</xsl:text>

        <!-- dc.identifier.scielo -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="dcvalue[@element='identifier' and @qualifier='scielo']" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.identifier.scopus -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="dcvalue[@element='identifier' and @qualifier='scopus']" />
        <xsl:text>&quot;</xsl:text>

        <!-- dc.identifier.wos -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="dcvalue[@element='identifier' and @qualifier='wos']" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.language.iso -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="string-join(distinct-values(dcvalue[@element='language' and @qualifier='iso']),'||')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.publisher -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="string-join(distinct-values(dcvalue[@element='publisher' and not(@qualifier)]),'||')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.relation.ispartof e dc.relation.isPartOf [OBSOLETO] -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="replace(dcvalue[@element='relation' and @qualifier='ispartof'],'&quot;','')" />
        <xsl:value-of select="replace(dcvalue[@element='relation' and @qualifier='isPartOf'],'&quot;','')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.rights.accessRights -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="dcvalue[@element='rights' and @qualifier='accessRights']" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.source -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="dcvalue[@element='source']" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.subject -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="replace(string-join(distinct-values(dcvalue[@element='subject' and not(@language)]),'||'),'&quot;','')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.subject[en] -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="replace(string-join(distinct-values(dcvalue[@element='subject' and @language='en']),'||'),'&quot;','')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.subject[pt] -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="replace(string-join(distinct-values(dcvalue[@element='subject' and @language='pt']),'||'),'&quot;','')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.title -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="replace(dcvalue[@element='title' and not(@language) and not(@qualifier)],'&quot;','')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.title[en] -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="replace(dcvalue[@element='title' and @language='en' and not(@qualifier)],'&quot;','')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.title[es] -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="replace(dcvalue[@element='title' and @language='es' and not(@qualifier)],'&quot;','')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.title[fr] -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="replace(dcvalue[@element='title' and @language='fr' and not(@qualifier)],'&quot;','')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.title[pt] -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="replace(dcvalue[@element='title' and @language='pt' and not(@qualifier)],'&quot;','')" />
        <xsl:text>&quot;</xsl:text>

        <!-- dc.title.alternative -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="replace(string-join(distinct-values(dcvalue[@element='title' and @qualifier='alternative' and not(@language)]),'||'),'&quot;','')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.title.alternative[en] -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="replace(dcvalue[@element='title' and @qualifier='alternative' and @language='en'],'&quot;','')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.title.alternative[es] -->
        
        <xsl:text>,&quot;</xsl:text>
            <xsl:value-of select="replace(dcvalue[@element='title' and @qualifier='alternative' and @language='es'],'&quot;','')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.title.alternative[fr] -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="replace(dcvalue[@element='title' and @qualifier='alternative' and @language='fr'],'&quot;','')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.title.alternative[pt] -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="replace(dcvalue[@element='title' and @qualifier='alternative' and @language='pt'],'&quot;','')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dc.type -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="string-join(distinct-values(dcvalue[@element='type']),'||')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- Metadados do namespace dcterms -->
        
        <!-- dcterms.license e dc.rights.license [OBSOLETO] -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="string-join(dcvalue[@element='license'],'||')" />
        <xsl:value-of select="string-join(dcvalue[@element='rights' and @qualifier='license'],'||')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- dcterms.rightsHolder e dc.rights.rightsHolder [OBSOLETO] -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="replace(string-join(distinct-values(dcvalue[@element='rightsHolder']),'||'),'&quot;','')" />
        <xsl:value-of select="replace(string-join(distinct-values(dcvalue[@element='rights' and @qualifier='rightsHolder']),'||'),'&quot;','')" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- Metadados do namespace unesp -->

        <!-- unesp.campus -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="dcvalue[@element='campus']" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- unesp.department -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="dcvalue[@element='department']" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- unesp.graduateProgram -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="dcvalue[@element='graduateProgram']" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- unesp.knowledgeArea -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="dcvalue[@element='knowledgeArea']" />
        <xsl:text>&quot;</xsl:text>
        
        <!-- unesp.researchArea -->
        
        <xsl:text>,&quot;</xsl:text>
        <xsl:value-of select="dcvalue[@element='researchArea']" />
        <xsl:text>&quot;</xsl:text>
    	
    	<!-- unesp.undergraduate -->
    	
    	<xsl:text>,&quot;</xsl:text>
    	<xsl:value-of select="dcvalue[@element='undergraduate']" />
    	<xsl:text>&quot;</xsl:text>
        
        <!-- Adiciona uma quebra de linha -->

        <xsl:text>&#xa;</xsl:text>
        
    </xsl:template>
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Oct 25, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> Fabrício Silva Assumpção</xd:p>
        </xd:desc>
    </xd:doc>
</xsl:stylesheet>

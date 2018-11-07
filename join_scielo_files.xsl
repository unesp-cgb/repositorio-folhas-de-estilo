<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

	<!-- Folha de estilo para reunir os arquivos XML da SciELO -->
	<!-- Última atualização: 2015-03-12 -->

	<xsl:template match="/">
		<articles>
			
			<!-- Incluir o endereço dos arquivos que serão reunidos -->
			
			<xsl:copy-of select="collection('file:///D:/XML/?select=*.xml')"/>

		</articles>
	</xsl:template>

</xsl:stylesheet>

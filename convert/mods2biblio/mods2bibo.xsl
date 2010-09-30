<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    exclude-result-prefixes="xs" version="2.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Sep 29, 2010</xd:p>
            <xd:p><xd:b>Author:</xd:b> tom</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:param name="noidpfx">p</xsl:param>
    <xsl:param name="noidurl">http://biblio.atlantides.org/item/</xsl:param>
    <xsl:output encoding="UTF-8" method="text" indent="no"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="mods:modsCollection">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="mods:mods">
        <xsl:variable name="noid">
            <xsl:call-template name="get-noid"/>
        </xsl:variable>
        
        
        <xsl:text></xsl:text>&lt;<xsl:value-of select="$noid"/>&gt; &lt;http://www.w3.org/1999/02/22-rdf-syntax-ns#type&gt; <xsl:apply-templates select="mods:genre"/> .<xsl:text>
</xsl:text><xsl:apply-templates select="mods:name"><xsl:with-param name="noid" select="$noid"/></xsl:apply-templates>
        <xsl:apply-templates select="mods:titleInfo[@type='abbreviated']"><xsl:with-param name="noid" select="$noid"/></xsl:apply-templates>
        <xsl:apply-templates select="mods:titleInfo[@type='uniform']"><xsl:with-param name="noid" select="$noid"/></xsl:apply-templates>
        <xsl:apply-templates select="mods:note[@type='citation']"><xsl:with-param name="noid" select="$noid"/></xsl:apply-templates>
        <xsl:apply-templates select="mods:originInfo/mods:dateIssued"><xsl:with-param name="noid" select="$noid"/></xsl:apply-templates>
        <xsl:apply-templates select="mods:relatedItem[@type='host']/mods:part/mods:date"><xsl:with-param name="noid" select="$noid"/></xsl:apply-templates>
        <xsl:apply-templates select="mods:location/mods:url"><xsl:with-param name="noid" select="$noid"/></xsl:apply-templates>
        <xsl:apply-templates select="mods:relatedItem[@type='host' and @xlink:href]"><xsl:with-param name="noid" select="$noid"/></xsl:apply-templates>
    </xsl:template>
            
    
    <xsl:template name="get-noid">
        <xsl:text></xsl:text><xsl:value-of select="$noidurl"/><xsl:value-of select="$noidpfx"/><xsl:value-of select="count(preceding-sibling::mods:mods) + 1"/><xsl:text></xsl:text>
    </xsl:template>
    
    <xsl:template match="mods:genre[not(@authority) or @authority='local']">
         <xsl:text></xsl:text>&lt;<xsl:choose>
            <xsl:when test=". = 'book'">
                <xsl:text></xsl:text>http://purl.org/ontology/bibo/Book<xsl:text></xsl:text>
            </xsl:when>
            <xsl:when test=". = 'article'">
                <xsl:text></xsl:text>http://purl.org/ontology/bibo/Article<xsl:text></xsl:text>
            </xsl:when>
            <xsl:when test=". = 'journal'">
                <xsl:text></xsl:text>http://purl.org/ontology/bibo/Journal<xsl:text></xsl:text>
            </xsl:when>
            <xsl:when test=". = 'collection'">
                <xsl:text></xsl:text>http://purl.org/ontology/bibo/Collection<xsl:text></xsl:text>
            </xsl:when>
            <xsl:when test=". = 'series'">
                <xsl:text></xsl:text>http://purl.org/ontology/bibo/Series<xsl:text></xsl:text>
            </xsl:when>
            <xsl:when test=". = 'multi-volume work'">
                <xsl:text></xsl:text>http://purl.org/ontology/bibo/MultiVolumeBook<xsl:text></xsl:text>
            </xsl:when>
             <xsl:when test=". = 'volume'">
                 <xsl:text></xsl:text>http://purl.org/ontology/bibo/Book<xsl:text></xsl:text>
             </xsl:when>
             <xsl:when test="@authority='local' and . = 'conferencePaper'">
                 <xsl:text></xsl:text>http://purl.org/ontology/bibo/Article<xsl:text></xsl:text>
             </xsl:when>
             <xsl:when test="@authority='local' and . = 'journalArticle'">
                 <xsl:text></xsl:text>http://purl.org/ontology/bibo/Article<xsl:text></xsl:text>
             </xsl:when>
             <xsl:otherwise>
                 <xsl:text>untrapped genre/work type in source data</xsl:text>
             </xsl:otherwise>
         </xsl:choose>&gt;<xsl:text></xsl:text>
    </xsl:template>
    
    <xsl:template match="mods:genre[@authority='marcgt']"/>
    
    <xsl:template match="mods:name[@type='corporate']">
        <xsl:param name="noid"/>
        <xsl:text></xsl:text>&lt;<xsl:value-of select="$noid"/>&gt; &lt;http://purl.org/dc/terms/creator&gt; "<xsl:call-template name="escapetext"><xsl:with-param  name="thestring"  select="mods:namePart"/></xsl:call-template>" .<xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template match="mods:name[@type='personal']">
        <xsl:param name="noid"/>
        <xsl:text></xsl:text>&lt;<xsl:value-of select="$noid"/>&gt; &lt;http://purl.org/dc/terms/creator&gt; "<xsl:call-template name="escapetext"><xsl:with-param  name="thestring"  select="mods:namePart[@type='family']"/></xsl:call-template>, <xsl:call-template name="escapetext"><xsl:with-param  name="thestring"  select="mods:namePart[@type='given']"/></xsl:call-template>" .<xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template match="mods:titleInfo[@type='uniform']">
        <xsl:param name="noid"/>
        <xsl:text></xsl:text>&lt;<xsl:value-of select="$noid"/>&gt; &lt;http://purl.org/dc/terms/title&gt; "<xsl:call-template name="escapetext"><xsl:with-param  name="thestring" select="mods:title"/></xsl:call-template>" .<xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template match="mods:titleInfo[@type='abbreviated']">
        <xsl:param name="noid"/>
        <xsl:text></xsl:text>&lt;<xsl:value-of select="$noid"/>&gt; &lt;http://purl.org/ontology/bibo/shortTitle&gt; "<xsl:call-template name="escapetext"><xsl:with-param  name="thestring" select="mods:title"/></xsl:call-template>" .<xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template match="mods:note[@type='citation']">
        <xsl:param name="noid"/>
        <xsl:text></xsl:text>&lt;<xsl:value-of select="$noid"/>&gt; &lt;http://purl.org/dc/terms/bibliographicCitation&gt;  "<xsl:call-template name="escapetext"><xsl:with-param name="thestring" select="."/></xsl:call-template>" .<xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template match="mods:dateIssued[@point='start' and ../mods:issuance='continuing']">
        <xsl:param name="noid"/>
        <xsl:text></xsl:text>&lt;<xsl:value-of select="$noid"/>&gt; &lt;http://purl.org/dc/terms/date&gt;  "<xsl:call-template name="escapetext"><xsl:with-param name="thestring" select="."/></xsl:call-template>-" .<xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template match="mods:dateIssued[@point='start' and ../mods:issuance != 'continuing']">
        <xsl:param name="noid"/>
        <xsl:text></xsl:text>&lt;<xsl:value-of select="$noid"/>&gt; &lt;http://purl.org/dc/terms/date&gt;  "<xsl:call-template name="escapetext"><xsl:with-param name="thestring" select="."/></xsl:call-template>-<xsl:call-template name="escapetext"><xsl:with-param name="thestring" select="../mods:dateIssued[@point='end']"/></xsl:call-template>" .<xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template match="mods:dateIssued[not(@point)]">
        <xsl:param name="noid"/>
        <xsl:text></xsl:text>&lt;<xsl:value-of select="$noid"/>&gt; &lt;http://purl.org/dc/terms/date&gt;  "<xsl:call-template name="escapetext"><xsl:with-param name="thestring" select="."/></xsl:call-template>" .<xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template match="mods:dateIssued[@point='end']"/>
    
    <xsl:template match="mods:date[ancestor::mods:relatedItem[@type='host']]">
        <xsl:param name="noid"/>
        <xsl:text></xsl:text>&lt;<xsl:value-of select="$noid"/>&gt; &lt;http://purl.org/dc/terms/date&gt;  "<xsl:call-template name="escapetext"><xsl:with-param name="thestring" select="."/></xsl:call-template>" .<xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template match="mods:url[parent::mods:location]">
        <xsl:param name="noid"/>
        <xsl:text></xsl:text>&lt;<xsl:value-of select="$noid"/>&gt; &lt;http://www.w3.org/2002/07/owl#sameAs&gt; &lt;<xsl:value-of select="."/>&gt; .<xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template match="mods:relatedItem[@type='host' and @xlink:href]">
        <xsl:param name="noid"/>
        <xsl:variable name="targetID" select="substring-before(@xlink:href, '.xml')"/>
        <xsl:message>looking for <xsl:value-of select="$targetID"/></xsl:message>
        <xsl:text></xsl:text>&lt;<xsl:value-of select="$noid"/>&gt; &lt;http://purl.org/dc/terms/isPartOf&gt;  &lt;<xsl:for-each select="//mods:mods[@ID=$targetID]"><xsl:call-template name="get-noid"/></xsl:for-each>&gt; .<xsl:text>
</xsl:text>
    </xsl:template>
    
    <xsl:template name="escapetext">
        <xsl:param name="thestring"/>
        <xsl:text></xsl:text><xsl:value-of select="replace(normalize-space($thestring), '&quot;', '\\&quot;')"/><xsl:text></xsl:text>
    </xsl:template>
    
</xsl:stylesheet>

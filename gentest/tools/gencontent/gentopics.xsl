<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Producing test DITA content for the feedbak servers  
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cpm="CPM"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="cpm xs" version="2.0">

    <!--
        Input parameters
    -->

    <!-- Where to put generated content? -->
    <xsl:param name="outRootPath"/>


    <!-- 
        Default processing
    -->

    <xsl:template match="row" mode="outFilename"/>
    <xsl:template match="row" mode="outPath"/>
    <xsl:template match="row" mode="ditaInnerContent"/>
    <xsl:template match="row" mode="ditaWriteOut"/>


    <!-- 
        Common functions
    -->

    <xsl:function name="cpm:joinPaths">
        <xsl:param name="path1"/>
        <xsl:param name="path2"/>
        <xsl:choose>
            <xsl:when test="$path1">
                <xsl:value-of select="concat($path1, '/', $path2)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$path2"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="cpm:outFilename">
        <xsl:param name="row"/>
        <xsl:apply-templates select="$row" mode="outFilename"/>
    </xsl:function>

    <xsl:function name="cpm:outFolderPath">
        <xsl:param name="row"/>
        <xsl:apply-templates select="$row" mode="outPath"/>
    </xsl:function>

    <xsl:function name="cpm:outFilePath">
        <xsl:param name="row"/>
        <xsl:value-of select="cpm:joinPaths(cpm:outFolderPath($row), cpm:outFilename($row))"/>
    </xsl:function>

    <xsl:function name="cpm:outRootPath">
        <xsl:value-of select="$outRootPath"/>
    </xsl:function>

    <xsl:function name="cpm:outFileFullPath">
        <xsl:param name="row"/>
        <xsl:value-of select="cpm:joinPaths(cpm:outRootPath(), cpm:outFilePath($row))"/>
    </xsl:function>


    <!-- 
        Common elements
    -->

    <xsl:template match="row" mode="ditaTitle">
        <title>
            <xsl:value-of select="title"/>
        </title>
    </xsl:template>


    <!-- 
        Genres and aspects
    -->

    <xsl:function name="cpm:genreAspectTable">
        <xsl:param name="handleElement"/>
        <xsl:copy-of select="root($handleElement)//genres_aspects"/>
    </xsl:function>

    <xsl:function name="cpm:isGenreAspectLink" as="xs:boolean">
        <xsl:param name="row"/>
        <xsl:param name="tgc"/>
        <xsl:param name="tac"/>
        <xsl:sequence select="$row/genre_code = $tgc and $row/aspect_code = $tac"/>
    </xsl:function>

    <xsl:function name="cpm:doesGenreHaveAspect" as="xs:boolean">
        <xsl:param name="gat"/>
        <xsl:param name="tgc"/>
        <xsl:param name="tac"/>
        <xsl:sequence select="exists($gat//row[cpm:isGenreAspectLink(., $tgc, $tac)])"/>
    </xsl:function>


    <!-- 
        Metadata
    -->

    <!-- Representing metadata in topics -->

    <!-- Retrieving titles -->

    <xsl:template match="*" mode="titleByCodeElm"/>

    <xsl:template match="pg_code" mode="titleByCodeElm">
        <xsl:value-of select="//product_groups//row[code = current()]/title"/>
    </xsl:template>

    <xsl:template match="ps_code" mode="titleByCodeElm">
        <xsl:value-of select="//product_subgroups//row[code = current()]/title"/>
    </xsl:template>

    <xsl:template match="technology_code" mode="titleByCodeElm">
        <xsl:value-of select="//technologies//row[code = current()]/title"/>
    </xsl:template>

    <xsl:function name="cpm:titleByCodeElm">
        <xsl:param name="codeElement"/>
        <xsl:apply-templates select="$codeElement" mode="titleByCodeElm"/>
    </xsl:function>

    <!-- Assigning taxonomy to a topic: product groups & subgroups -->

    <xsl:template match="product_groups//row" mode="ditaTaxonomyOthermeta">
        <othermeta name="Product" props="{code}" otherprops="taxonomy" content="{title}"/>
    </xsl:template>

    <xsl:template match="product_subgroups//row" mode="ditaTaxonomyOthermeta">
        <othermeta name="Product" props="{code}" otherprops="taxonomy" content="{title}"/>
    </xsl:template>

    <xsl:template match="row[cpm:isTopic(.) and ps_code = 'null']" mode="ditaTaxonomyProduct">
        <xsl:apply-templates select="//product_groups//row[code = current()/pg_code]"
            mode="ditaTaxonomyOthermeta"/>
    </xsl:template>
    
    <xsl:template match="row[cpm:isTopic(.) and ps_code != 'null']" mode="ditaTaxonomyProduct">
        <othermeta name="Product" props="{ps_code}" otherprops="taxonomy"
            content="{cpm:titleByCodeElm(ps_code)}"/>
    </xsl:template>

    <!-- Assigning taxonomy to a topic: technologies -->
    
    <xsl:template match="technologies//row" mode="ditaTaxonomyOthermeta">
        <othermeta name="Technology" props="{code}" otherprops="taxonomy" content="{title}"/>
    </xsl:template>

    <xsl:template match="row[cpm:isTopic(.) and technology_code = 'null']"
        mode="ditaTaxonomyTechnology">
        <xsl:apply-templates select="//technologies//row" mode="ditaTaxonomyOthermeta"/>
    </xsl:template>

    <xsl:template match="row[cpm:isTopic(.) and technology_code != 'null']"
        mode="ditaTaxonomyTechnology">

        <xsl:apply-templates select="//technologies//row[code = current()/technology_code]"
            mode="ditaTaxonomyOthermeta"/>
        <!--
        <othermeta name="Technology" props="{technology_code}" otherprops="taxonomy"
            content="{cpm:titleByCodeElm(technology_code)}"/>
        -->
    </xsl:template>

    <!-- Assigning taxonome to a topic: subjects -->

    <xsl:function name="cpm:isRelated" as="xs:boolean">
        <xsl:param name="rowTopic"/>
        <xsl:param name="rowSubject"/>
        <xsl:sequence
            select="exists(root($rowTopic)//gtopics_subjects//row[topic_code = $rowTopic/code and subject_code = $rowSubject/code])"
        />
    </xsl:function>

    <xsl:template match="row[cpm:isTopic(.)]" mode="ditaTaxonomySubject">
        <xsl:for-each select="//subjects//row[cpm:isRelated(current(), .)]">
            <othermeta name="Subject" props="{code}" otherprops="taxonomy" content="{title}"/>
        </xsl:for-each>
    </xsl:template>

    <!-- Assigning taxonomy to a topic: all the kinds -->

    <xsl:template match="row[cpm:isTopic(.)]" mode="ditaTaxonomy">
        <xsl:apply-templates select="." mode="ditaTaxonomyProduct"/>
        <xsl:apply-templates select="." mode="ditaTaxonomyTechnology"/>
        <xsl:apply-templates select="." mode="ditaTaxonomySubject"/>
    </xsl:template>

    <xsl:template match="row[cpm:isTopic(.)]" mode="ditaProlog">
        <prolog>
            <metadata>
                <xsl:apply-templates select="." mode="ditaTaxonomy"/>
            </metadata>
        </prolog>
    </xsl:template>

    <!-- A subject map -->

    <xsl:template match="row" mode="ditaKeys">
        <xsl:value-of select="title"/>
    </xsl:template>

    <xsl:function name="cpm:ditaKeys">
        <xsl:param name="row"/>
        <xsl:apply-templates select="$row" mode="ditaKeys"/>
    </xsl:function>

    <xsl:template match="product_subgroups//row" mode="ditaTaxonomy">
        <subjectdef keys="{cpm:ditaKeys(.)}"/>
    </xsl:template>

    <xsl:template match="product_groups//row" mode="ditaTaxonomy">
        <subjectdef keys="{cpm:ditaKeys(.)}">
            <xsl:apply-templates select="//product_subgroups//row[pg_code = current()/code]"
                mode="ditaTaxonomy"/>
        </subjectdef>
    </xsl:template>

    <xsl:template match="product_groups" mode="ditaTaxonomy">
        <subjectdef keys="Products">
            <xsl:apply-templates select=".//row" mode="ditaTaxonomy"/>
        </subjectdef>
    </xsl:template>

    <xsl:template match="technologies//row" mode="ditaTaxonomy">
        <subjectdef keys="{cpm:ditaKeys(.)}"/>
    </xsl:template>

    <xsl:template match="technologies" mode="ditaTaxonomy">
        <subjectdef keys="Technologies">
            <xsl:apply-templates select=".//row" mode="ditaTaxonomy"/>
        </subjectdef>
    </xsl:template>

    <xsl:template match="subjects//row" mode="ditaTaxonomy">
        <subjectdef keys="{cpm:ditaKeys(.)}"/>
    </xsl:template>

    <xsl:template match="subjects" mode="ditaTaxonomy">
        <subjectdef keys="Subjects">
            <xsl:apply-templates select=".//row" mode="ditaTaxonomy"/>
        </subjectdef>
    </xsl:template>

    <xsl:template match="taxonomy" mode="ditaSubjectMap">
        <subjectScheme>
            <xsl:apply-templates select="//product_groups" mode="ditaTaxonomy"/>
            <xsl:apply-templates select="//technologies" mode="ditaTaxonomy"/>
            <xsl:apply-templates select="//subjects" mode="ditaTaxonomy"/>
        </subjectScheme>
    </xsl:template>

    <xsl:template match="taxonomy" mode="outFilename">
        <xsl:value-of select="'taxonomy.xml'"/>
    </xsl:template>

    <xsl:function name="cpm:ditaTaxonomyFullPath">
        <xsl:value-of select="cpm:joinPaths(cpm:outRootPath(), 'taxonomy.xml')"/>
    </xsl:function>

    <xsl:template match="taxonomy" mode="ditaWriteOut">
        <xsl:result-document href="{cpm:ditaTaxonomyFullPath()}" indent="yes"
            doctype-public="-//OASIS//DTD DITA Subject Scheme Map//EN"
            doctype-system="subjectScheme.dtd">
            <xsl:apply-templates select="." mode="ditaSubjectMap"/>
        </xsl:result-document>
    </xsl:template>


    <!-- 
        Topics
    -->

    <!-- Detecting topics -->

    <xsl:template match="row" mode="isTopic" as="xs:boolean">
        <xsl:value-of select="exists(ancestor::topics)"/>
    </xsl:template>

    <xsl:function name="cpm:isTopic" as="xs:boolean">
        <xsl:param name="row"/>
        <xsl:apply-templates select="$row" mode="isTopic"/>
    </xsl:function>


    <!-- Detecting group topics -->

    <xsl:template match="row" mode="isGroupTopic" as="xs:boolean">
        <xsl:sequence select="false()"/>
    </xsl:template>

    <xsl:template match="row[cpm:isTopic(.)]" mode="isGroupTopic" as="xs:boolean">
        <xsl:value-of select="pg_code != 'null' and ps_code = 'null' and technology_code = 'null'"/>
    </xsl:template>

    <xsl:function name="cpm:isGroupTopic" as="xs:boolean">
        <xsl:param name="row"/>
        <xsl:apply-templates select="$row" mode="isGroupTopic"/>
    </xsl:function>


    <!-- Detecting subgroup topics -->

    <xsl:template match="row" mode="isSubgroupTopic" as="xs:boolean">
        <xsl:sequence select="false()"/>
    </xsl:template>

    <xsl:template match="row[cpm:isTopic(.)]" mode="isSubgroupTopic" as="xs:boolean">
        <xsl:value-of select="pg_code != 'null' and ps_code != 'null' and technology_code = 'null'"
        />
    </xsl:template>

    <xsl:function name="cpm:isSubgroupTopic" as="xs:boolean">
        <xsl:param name="row"/>
        <xsl:apply-templates select="$row" mode="isSubgroupTopic"/>
    </xsl:function>


    <!-- Detecting product topics -->

    <xsl:template match="row" mode="isProductTopic" as="xs:boolean">
        <xsl:sequence select="false()"/>
    </xsl:template>

    <xsl:template match="row[cpm:isTopic(.)]" mode="isProductTopic" as="xs:boolean">
        <xsl:value-of select="pg_code != 'null' and ps_code != 'null' and technology_code != 'null'"
        />
    </xsl:template>

    <xsl:function name="cpm:isProductTopic" as="xs:boolean">
        <xsl:param name="row"/>
        <xsl:apply-templates select="$row" mode="isProductTopic"/>
    </xsl:function>


    <!-- Inner content for topics -->

    <xsl:template match="row[cpm:isTopic(.)]" mode="ditaInnerContent">
        <body>
            <p>Alice was beginning to get very tired of sitting by her sister on the bank, and of
                having nothing to do: once or twice she had peeped into the book her sister was
                reading, but it had no pictures or conversations in it, “and what is the use of a
                book,” thought Alice “without pictures or conversations?”</p>
            <p>So she was considering in her own mind (as well as she could, for the hot day made
                her feel very sleepy and stupid), whether the pleasure of making a daisy-chain would
                be worth the trouble of getting up and picking the daisies, when suddenly a White
                Rabbit with pink eyes ran close by her.</p>
            <p>There was nothing so very remarkable in that; nor did Alice think it so very much out
                of the way to hear the Rabbit say to itself, “Oh dear! Oh dear! I shall be late!”
                (when she thought it over afterwards, it occurred to her that she ought to have
                wondered at this, but at the time it all seemed quite natural); but when the Rabbit
                actually took a watch out of its waistcoat-pocket, and looked at it, and then
                hurried on, Alice started to her feet, for it flashed across her mind that she had
                never before seen a rabbit with either a waistcoat-pocket, or a watch to take out of
                it, and burning with curiosity, she ran across the field after it, and fortunately
                was just in time to see it pop down a large rabbit-hole under the hedge.</p>
        </body>
    </xsl:template>

    <xsl:template match="row[cpm:isTopic(.)]" mode="ditaDoc">
        <topic id="{code}" xml:lang="{lang_code}">
            <xsl:apply-templates select="." mode="ditaTitle"/>
            <xsl:apply-templates select="." mode="ditaProlog"/>
            <xsl:apply-templates select="." mode="ditaInnerContent"/>
        </topic>
    </xsl:template>


    <!-- Writing topics -->

    <xsl:template match="row[cpm:isTopic(.)]" mode="outFilename">
        <xsl:value-of select="concat(code, '.dita')"/>
    </xsl:template>

    <xsl:template match="row[cpm:isGroupTopic(.)]" mode="outPath">
        <xsl:value-of select="concat(lang_code, '/', pg_code)"/>
    </xsl:template>

    <xsl:template match="row[cpm:isSubgroupTopic(.)]" mode="outPath">
        <xsl:value-of select="concat(lang_code, '/', pg_code, '/', ps_code)"/>
    </xsl:template>

    <xsl:template match="row[cpm:isProductTopic(.)]" mode="outPath">
        <xsl:value-of select="concat(lang_code, '/', pg_code, '/', ps_code, '/', technology_code)"/>
    </xsl:template>

    <xsl:function name="cpm:productPath">
        <xsl:param name="handleElement"/>
        <xsl:param name="target_product_code"/>
        <xsl:param name="target_lang_code"/>
        <xsl:apply-templates
            select="root($handleElement)//row[cpm:isTopic(.) and product_code = $target_product_code and lang_code = $target_lang_code][1]"
            mode="outPath"/>
    </xsl:function>

    <xsl:template match="row[cpm:isTopic(.)]" mode="ditaWriteOut">
        <xsl:result-document href="{cpm:outFileFullPath(.)}" indent="yes"
            doctype-public="-//OASIS//DTD DITA Topic//EN" doctype-system="topic.dtd">
            <xsl:apply-templates select="." mode="ditaDoc"/>
        </xsl:result-document>
    </xsl:template>


    <!--
        Maps
    -->

    <xsl:template match="row" mode="isOnlineDoc" as="xs:boolean">
        <xsl:value-of select="exists(ancestor::online_docs)"/>
    </xsl:template>

    <xsl:function name="cpm:isOnlineDoc" as="xs:boolean">
        <xsl:param name="row"/>
        <xsl:apply-templates select="$row" mode="isOnlineDoc"/>
    </xsl:function>

    <xsl:template match="row" mode="ditaTopicref">
        <topicref href="{cpm:outFilename(.)}"/>
    </xsl:template>

    <xsl:function name="cpm:contains" as="xs:boolean">
        <xsl:param name="onlineDoc"/>
        <xsl:param name="topic"/>

        <xsl:variable name="productIsSame" select="$onlineDoc/product_code = $topic/product_code"
            as="xs:boolean"/>

        <xsl:variable name="gat" select="cpm:genreAspectTable($onlineDoc)"/>
        <xsl:variable name="aspectMatchesGenre"
            select="cpm:doesGenreHaveAspect($gat, $onlineDoc/genre_code, $topic/aspect_code)"/>

        <xsl:variable name="langIsSame" select="$onlineDoc/lang_code = $topic/lang_code"/>

        <xsl:sequence select="$productIsSame and $langIsSame and $aspectMatchesGenre"/>
    </xsl:function>

    <xsl:template match="row[cpm:isOnlineDoc(.)]" mode="ditaInnerContent">
        <xsl:apply-templates select="//row[cpm:isTopic(.)][cpm:contains(current(), .)]"
            mode="ditaTopicref"/>
    </xsl:template>

    <xsl:template match="row[cpm:isOnlineDoc(.)]" mode="ditaDoc">
        <map id="{code}" xml:lang="{lang_code}">
            <xsl:apply-templates select="." mode="ditaTitle"/>
            <xsl:apply-templates select="." mode="ditaInnerContent"/>
        </map>
    </xsl:template>

    <xsl:template match="row[cpm:isOnlineDoc(.)]" mode="outFilename">
        <xsl:value-of select="concat(code, '.ditamap')"/>
    </xsl:template>

    <xsl:template match="row[cpm:isOnlineDoc(.)]" mode="outPath">
        <xsl:value-of select="cpm:productPath(., product_code, lang_code)"/>
    </xsl:template>

    <xsl:template match="row[cpm:isOnlineDoc(.)]" mode="ditaWriteOut">
        <xsl:result-document href="{cpm:outFileFullPath(.)}" indent="yes"
            doctype-public="-//OASIS//DTD DITA Map//EN" doctype-system="map.dtd">
            <xsl:apply-templates select="." mode="ditaDoc"/>
        </xsl:result-document>
    </xsl:template>


    <!-- 
        Main    
    -->

    <xsl:template match="/">

        <!-- Producing topics -->
        <xsl:apply-templates select="//topics/data/row" mode="ditaWriteOut"/>

        <!-- Producing document maps -->
        <xsl:apply-templates select="//online_docs/data/row" mode="ditaWriteOut"/>

        <!-- Producing a subject map for the taxonomy -->
        <xsl:apply-templates select="//taxonomy" mode="ditaWriteOut"/>

    </xsl:template>

</xsl:stylesheet>

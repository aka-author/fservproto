<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cpm="CPM"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="cpm xs" version="2.0">

    <!-- Where to put generated content? -->
    <xsl:param name="outRootPath"/>


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
        <xsl:value-of select="cpm:isTopic(.) and ps_code = 'null'"/>
    </xsl:template>

    <xsl:function name="cpm:isGroupTopic" as="xs:boolean">
        <xsl:param name="row"/>
        <xsl:apply-templates select="$row" mode="isGroupTopic"/>
    </xsl:function>


    <!-- Detecting subgroup topics -->

    <xsl:template match="row" mode="isSubgroupTopic" as="xs:boolean">
        <xsl:value-of select="cpm:isTopic(.) and ps_code != 'null' and predicate_code = 'null'"/>
    </xsl:template>

    <xsl:function name="cpm:isSubgroupTopic" as="xs:boolean">
        <xsl:param name="row"/>
        <xsl:apply-templates select="$row" mode="isSubgroupTopic"/>
    </xsl:function>


    <!-- Detecting product topics -->

    <xsl:template match="row" mode="isProductTopic" as="xs:boolean">
        <xsl:value-of select="cpm:isTopic(.) and predicate_code != 'null'"/>
    </xsl:template>

    <xsl:function name="cpm:isProductTopic" as="xs:boolean">
        <xsl:param name="row"/>
        <xsl:apply-templates select="$row" mode="isProductTopic"/>
    </xsl:function>

    <!-- Topic or map filename -->

    <xsl:template match="row[cpm:isTopic(.)]" mode="outFilename">
        <xsl:value-of select="concat(topic_id, '.dita')"/>
    </xsl:template>

    <xsl:template match="online_docs//row" mode="outFilename">
        <xsl:value-of select="concat(topic_id, '.dita')"/>
    </xsl:template>

    <xsl:function name="cpm:outFilename">
        <xsl:param name="topicRow"/>
        <xsl:apply-templates select="$topicRow" mode="outFilename"/>
    </xsl:function>


    <!-- Relative path -->

    <xsl:template match="row[cpm:isGroupTopic(.)]" mode="outPath">
        <xsl:value-of select="pg_code"/>
    </xsl:template>

    <xsl:template match="row[cpm:isSubgroupTopic(.)]" mode="outPath">
        <xsl:value-of select="concat(pg_code, '/', ps_code)"/>
    </xsl:template>

    <xsl:template match="row[cpm:isProductTopic(.)]" mode="outPath">
        <xsl:value-of select="concat(pg_code, '/', ps_code, '/', predicate_code)"/>
    </xsl:template>


    <xsl:template match="row[cpm:isOnlineDoc(.)]" mode="outPath">
        <xsl:value-of select="cpm:productPath(product_code)"/>
    </xsl:template>

    <xsl:function name="cpm:outPath">
        <xsl:param name="row"/>
        <xsl:apply-templates select="$row" mode="outPath"/>
    </xsl:function>


    <!-- Topic full path -->

    <xsl:function name="cpm:outRootPath">
        <xsl:value-of select="$outRootPath"/>
    </xsl:function>

    <xsl:function name="cpm:outFullPath">
        <xsl:param name="topicRow"/>

        <xsl:variable name="relativePath"
            select="concat(cpm:outPath($topicRow), '/', cpm:outFilename($topicRow))"/>

        <xsl:variable name="outRootPath" select="cpm:outRootPath()"/>

        <xsl:choose>
            <xsl:when test="$outRootPath">
                <xsl:value-of select="concat($outRootPath, '/', $relativePath)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$relativePath"/>
            </xsl:otherwise>
        </xsl:choose>


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
        Topics
    -->

    <xsl:template match="row" mode="ditaBody">
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

    <xsl:template match="row" mode="ditaDoc">
        <topic id="{topic_id}" xml:lang="en">
            <xsl:apply-templates select="." mode="ditaTitle"/>
            <xsl:apply-templates select="." mode="ditaBody"/>
        </topic>
    </xsl:template>

    <xsl:template match="row[cpm:isTopic(.)]" mode="ditaWriteOut">
        <xsl:result-document href="{cpm:outFullPath(.)}" indent="yes"
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
        <topicref href="{cpm:outFilename(row)}" format="dita"/>
    </xsl:template>

    <xsl:function name="cpm:checkAspect" as="xs:boolean">
        <xsl:param name="online_doc"/>
        <xsl:param name="topic"/>
        <xsl:variable name="gc" select="$online_doc/genre_code"/>
        <xsl:variable name="ac" select="$topic/aspect_code"/>
        <xsl:value-of
            select="exists(root($online_doc)/genres_aspects/data/row[genre_code = $gc and aspect_code = $ac])"
        />
    </xsl:function>

    <xsl:function name="cpm:belongs" as="xs:boolean">
        <xsl:param name="online_doc"/>
        <xsl:param name="topic"/>
        <xsl:sequence select="cpm:isTopic($online_doc) and cpm:checkAspect($online_doc, $topic)"/>
    </xsl:function>

    <xsl:template match="row[cpm:isOnlineDoc(.)]" mode="ditaDoc">
        <map id="{online_doc_code}">
            <xsl:apply-templates select="." mode="ditaTitle"/>
            <xsl:apply-templates select="//row[cpm:belongs(current(), .)]" mode="ditaTopicref"/>
        </map>
    </xsl:template>

    <xsl:template match="row[cpm:isOnlineDoc(.)]" mode="ditaWriteOut">
        <xsl:result-document href="{cpm:outFullPath(.)}" indent="yes"
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

    </xsl:template>

</xsl:stylesheet>

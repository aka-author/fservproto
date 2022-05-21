<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cpm="CPM"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="cpm xs" version="2.0">

    <xsl:template match="row" mode="outPath">
        <xsl:value-of
            select="concat('products/', pg_code, '/', subject_code, '/', predicate_code, '/', topic_id, '.dita')"
        />
    </xsl:template>

    <xsl:function name="cpm:outPath">
        <xsl:param name="row"/>
        <xsl:apply-templates select="$row" mode="outPath"/>
    </xsl:function>

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

    <xsl:template match="row" mode="ditaTitle">
        <title>
            <xsl:value-of select="title"/>
        </title>
    </xsl:template>

    <xsl:template match="row" mode="ditaTopic">
        <topic id="{topic_id}" xml:lang="en">
            <xsl:apply-templates select="." mode="ditaTitle"/>
            <xsl:apply-templates select="." mode="ditaBody"/>
        </topic>
    </xsl:template>

    <xsl:template match="row" mode="ditaWriteOut">
        <xsl:if test="count(//row[topic_id = current()/topic_id]) = 1">
            <xsl:result-document href="{cpm:outPath(.)}" indent="yes"
                doctype-public="-//OASIS//DTD DITA Topic//EN" doctype-system="topic.dtd">
                <xsl:apply-templates select="." mode="ditaTopic"/>
            </xsl:result-document>
        </xsl:if>
    </xsl:template>

    <xsl:template match="/">
        <xsl:apply-templates select="//row" mode="ditaWriteOut"/>
    </xsl:template>

</xsl:stylesheet>

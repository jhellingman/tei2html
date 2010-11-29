<?xml version="1.0" encoding="iso-8859-1" ?>
<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet to define localized messages.

    This file is made available under the GNU General Public License, version 3.0 or later.

-->

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msg="http://www.gutenberg.ph/2006/schemas/messages"
    version="1.0"
    >


    <xsl:variable name="language" select="/TEI.2/@lang" />
    <xsl:variable name="baselanguage" select="substring-before($language,'-')" />
    <xsl:variable name="defaultlanguage" select="'en'" />
    <xsl:variable name="messages" select="document('messages.xml')/msg:repository"/>


    <!--====================================================================-->
    <!-- Pull strings into easier to use variables -->

    <xsl:variable name="strToc">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgToc'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strNote">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgNote'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strNotes">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgNote.n'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strFigure">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgFigure'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strPlate">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgPlate'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strPart">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgPart'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strTableOfContents">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgTableOfContents'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strAppendix">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgAppendix'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strPage">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgPage'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strHere">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgHere'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strNotApplicable">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgNotApplicable'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strNext">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgNext'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strPrevious">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgPrevious'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strChapter">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgChapter'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strBook">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgBook'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strAnd">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgAnd'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strListOfIllustrations">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgListOfIllustrations'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strListOfTables">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgListOfTables'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strAcknowledgements">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgAcknowledgements'"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="strCorrections">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgCorrection.n'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strCorrection">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgCorrection'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strTranscription">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgTranscription'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strSource">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgSource'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strLocation">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgLocation'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strCorrectionsAppliedToText">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgCorrectionsAppliedToText'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strCorrectionsOverview">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgCorrectionsOverview'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strColophon">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgColophon'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strGlossary">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgGlossary'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strApparatus">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgApparatus'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strRevisionHistory">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgRevisionHistory'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strAvailability">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgAvailability'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strEncoding">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgEncoding'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strOrnament">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgOrnament'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strNotInSource">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgNotInSource'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strDeleted">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgDeleted'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strCoverImage">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgCoverImage'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strTitlePage">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgTitlePage'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strDedication">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgDedication'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strEpigraph">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgEpigraph'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strIndex">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgIndex'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strBibliography">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgBibliography'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strCopyrightPage">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgCopyrightPage'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strPreface">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgPreface'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strText">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgText'"/>
        </xsl:call-template>
    </xsl:variable>


    <xsl:variable name="strExternalReferences">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgExternalReferences'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strExternalReferencesDisclaimer">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgExternalReferencesDisclaimer'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strOclcCatalogEntry">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgOclcCatalogEntry'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strOpenLibraryCatalogEntry">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgOpenLibraryCatalogEntry'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strPgCatalogEntry">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgPgCatalogEntry'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strLinkToPg">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgLinkToPg'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strLinkToOpenLibrary">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgLinkToOpenLibrary'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strLinkToWorldCat">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgLinkToWorldCat'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strLinkToWikipedia">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgLinkToWikipedia'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strLinkToWikiPilipinas">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgLinkToWikiPilipinas'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strLinkToMap">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgLinkToMap'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strLinkToBible">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgLinkToBible'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strExternalLink">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgExternalLink'"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="strNotCopyrightedUS">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgNotCopyrightedUS'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strMissingText">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgMissingText'"/>
        </xsl:call-template>
    </xsl:variable>

</xsl:stylesheet>

<!DOCTYPE xsl:stylesheet [

    <!ENTITY ndash      "&#x2013;">
    <!ENTITY eacute     "&#x00E9;">
    <!ENTITY ocirc      "&#x00F4;">
    <!ENTITY ccedil     "&#x00E7;">
    <!ENTITY rsquo      "&#x2019;">

]>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:f="urn:stylesheet-functions"
    exclude-result-prefixes="f xs xd">


    <xd:doc type="stylesheet">
        <xd:short>Functions to determine copyright status</xd:short>
        <xd:detail>This stylesheet contains a number of functions to determine copyright status of a TEI file, based on data in the header.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2018, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xsl:function name="f:in-copyright" as="xs:boolean">
        <xsl:param name="jurisdiction" as="xs:string"/>
        <xsl:param name="teiHeader" as="element(teiHeader)"/>

        <xsl:variable name="termInYears" select="f:copyright-term-in-years($jurisdiction)"/>

        <xsl:value-of select="f:last-contributor-death($teiHeader) > year-from-date(current-date()) - ($termInYears + 1)"/>
    </xsl:function>


    <xsl:function name="f:copyright-term-in-years" as="xs:integer">
        <xsl:param name="code" as="xs:string"/>

        <!--
        <xsl:message>JURISDICTION: <xsl:value-of select="$code"/></xsl:message>
        <xsl:message>NAME: <xsl:value-of select="$jurisdictions//jurisdiction[@code = $code]/@name"/></xsl:message>
        -->

        <xsl:variable name="rules"
            select="if ($jurisdictions//jurisdiction[@code = $code and @see])
                    then $jurisdictions//jurisdiction[@code = $jurisdictions//jurisdiction[@code = $code]/@see]
                    else $jurisdictions//jurisdiction[@code = $code]"/>

        <!--
        <xsl:message>RULE: <xsl:value-of select="$rules/rule[1]/@lifePlusYears"/></xsl:message>
        -->

        <xsl:variable name="lifePlusYears" select="$rules/rule[1]/@lifePlusYears"/>
        <xsl:value-of select="if ($lifePlusYears = 'XXX') then 100 else $lifePlusYears"/>
    </xsl:function>


    <xsl:function name="f:last-contributor-death">
        <xsl:param name="teiHeader" as="element(teiHeader)"/>

        <xsl:variable name="contributors">
            <contributors>
                <xsl:for-each select="$teiHeader/fileDesc/titleStmt/author">
                    <xsl:copy-of select="f:parse-name-with-dates(.)"/>
                </xsl:for-each>
                <xsl:for-each select="$teiHeader/fileDesc/titleStmt/editor">
                    <xsl:copy-of select="f:parse-name-with-dates(.)"/>
                </xsl:for-each>
                <xsl:for-each select="$teiHeader/fileDesc/titleStmt/respStmt/name">
                    <xsl:copy-of select="f:parse-name-with-dates(.)"/>
                </xsl:for-each>
            </contributors>
        </xsl:variable>

        <!-- <xsl:message>LAST DEATH <xsl:value-of select="if ($contributors//death[matches(., '[0-9]+')]) then max($contributors//death[matches(., '[0-9]+')]) else 0"/></xsl:message> -->

        <xsl:value-of select="if ($contributors//death[matches(., '[0-9]+')]) then max($contributors//death[matches(., '[0-9]+')]) else 0"/>
    </xsl:function>


    <xsl:function name="f:parse-name-with-dates">
        <xsl:param name="name" as="xs:string"/>

        <!-- <xsl:message>ANALYZING: <xsl:value-of select="$name"/></xsl:message> -->
        <xsl:choose>
            <xsl:when test="matches($name, '^(.+)[,]? [(]?([0-9]+)[&ndash;-]([0-9]+)[)]?\]?$')">
                <xsl:analyze-string select="$name" regex="^(.+)[,]? [(]?([0-9]+)[&ndash;-]([0-9]+)[)]?\]?$">
                    <xsl:matching-substring>
                        <contributor>
                            <!--
                            <xsl:message>FOUND NAME: <xsl:value-of select="regex-group(1)"/></xsl:message>
                            <xsl:message>FOUND BIRTH: <xsl:value-of select="regex-group(2)"/></xsl:message>
                            <xsl:message>FOUND DEATH: <xsl:value-of select="regex-group(3)"/></xsl:message>
                            -->
                            <name><xsl:value-of select="regex-group(1)"/></name>
                            <birth><xsl:value-of select="regex-group(2)"/></birth>
                            <death><xsl:value-of select="regex-group(3)"/></death>
                        </contributor>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches($name, '^(.+)[,]? [(]?[&ndash;-]([0-9]+)[)]?\]?$')">
                <xsl:analyze-string select="$name" regex="^(.+)[,]? [(]?[&ndash;-]([0-9]+)[)]?\]?$">
                    <xsl:matching-substring>
                        <contributor>
                            <name><xsl:value-of select="regex-group(1)"/></name>
                            <death><xsl:value-of select="regex-group(2)"/></death>
                        </contributor>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:when test="matches($name, '^(.+)[,]? [(]?([0-9]+)[&ndash;-][)]?\]?$')">
                <xsl:analyze-string select="$name" regex="^(.+)[,]? [(]?([0-9]+)[&ndash;-][)]?\]?$">
                    <xsl:matching-substring>
                        <contributor>
                            <name><xsl:value-of select="regex-group(1)"/></name>
                            <birth><xsl:value-of select="regex-group(2)"/></birth>
                        </contributor>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
                <contributor>
                    <name><xsl:value-of select="$name"/></name>
                </contributor>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xd:doc>
        <xd:short>Copyright Jurisdictions</xd:short>
        <xd:detail>A list of jurisdictions giving the copyright terms in force in those
        jurisdictions. Note that this is a gross simplification of the actual legal situation,
        aimed at quickly getting an indicative copyright status of literary works.</xd:detail>
    </xd:doc>

    <xsl:variable name="jurisdictions">
        <jurisdictions updated="2018-08-28">
            <!-- Supra-national organizations and treaties -->
            <jurisdiction code="EU" name="European Union"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="Bern" name="Bern Convention"><rule lifePlusYears="50"/></jurisdiction>

            <!-- Countries -->
            <jurisdiction code="AD" name="Andorra"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="AE" name="United Arab Emirates"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="AF" name="Afghanistan"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="AG" name="Antigua and Barbuda"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="AI" name="Anguilla"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="AL" name="Albania"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="AM" name="Armenia"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="AN" name="Netherlands Antilles"><rule lifePlusYears="50"/></jurisdiction> <!-- Now SX, CW, BQ -->

            <jurisdiction code="SX" name="Sint Maarten"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="CW" name="Cura&ccedil;ao"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="BX" name="Caribbean Netherlands" see="NL"/>

            <jurisdiction code="AO" name="Angola"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="AQ" name="Antarctica"><rule lifePlusYears="0"/></jurisdiction>
            <jurisdiction code="AR" name="Argentina"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="AS" name="American Samoa" see="US"/>
            <jurisdiction code="AT" name="Austria"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="AU" name="Australia">
                <rule lifePlusYears="70" fromDeathDate="1955-01-01"/>
                <rule lifePlusYears="50"/>
            </jurisdiction>
            <jurisdiction code="AW" name="Aruba"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="AX" name="Aland Islands" see="FI"/>
            <jurisdiction code="AZ" name="Azerbaijan"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="BA" name="Bosnia and Herzegovina"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="BB" name="Barbados"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="BD" name="Bangladesh"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="BE" name="Belgium"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="BF" name="Burkina Faso"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="BG" name="Bulgaria"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="BH" name="Bahrain"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="BI" name="Burundi"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="BJ" name="Benin"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="BL" name="Saint-Barth&eacute;lemy" see="FR"/>
            <jurisdiction code="BM" name="Bermuda"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="BN" name="Brunei Darussalam"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="BO" name="Bolivia"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="BR" name="Brazil"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="BS" name="Bahamas"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="BT" name="Bhutan"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="BV" name="Bouvet Island" see="NO"/>
            <jurisdiction code="BW" name="Botswana"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="BY" name="Belarus"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="BZ" name="Belize"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="CA" name="Canada"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="CC" name="Cocos (Keeling) Islands" see="AU"/>
            <jurisdiction code="CD" name="Democratic Republic of the Congo"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="CF" name="Central African Republic"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="CG" name="Republic of the Congo"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="CH" name="Switzerland">
                <rule lifePlusYears="70" fromDeathDate="1994-01-01"/>
                <rule lifePlusYears="50"/>
            </jurisdiction>
            <jurisdiction code="CI" name="C&ocirc;te d&rsquo;Ivoire"><rule lifePlusYears="99"/></jurisdiction>
            <jurisdiction code="CK" name="Cook Islands" see="NZ"/>
            <jurisdiction code="CL" name="Chile"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="CM" name="Cameroon"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="CN" name="China"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="CO" name="Colombia"><rule lifePlusYears="80"/></jurisdiction>
            <jurisdiction code="CR" name="Costa Rica"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="CU" name="Cuba"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="CV" name="Cape Verde"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="CX" name="Christmas Island" see="AU"/>
            <jurisdiction code="CY" name="Cyprus"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="CZ" name="Czech Republic"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="DE" name="Germany"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="DJ" name="Djibouti"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="DK" name="Denmark"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="DM" name="Dominica"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="DO" name="Dominican Republic"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="DZ" name="Algeria"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="EC" name="Ecuador"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="EE" name="Estonia"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="EG" name="Egypt"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="EH" name="Western Sahara" see="MA"/>
            <jurisdiction code="ER" name="Eritrea">
                <rule lifePlusYears="0" publicationPlusYears="50"/>
            </jurisdiction>
            <jurisdiction code="ES" name="Spain"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="ET" name="Ethiopia"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="FI" name="Finland"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="FJ" name="Fiji"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="FK" name="Falkland Islands" see="UK"/>
            <jurisdiction code="FM" name="Micronesia, Federated States of"><rule lifePlusYears="XXX"/></jurisdiction>
            <jurisdiction code="FO" name="Faroe Islands" see="DK"/>
            <jurisdiction code="FR" name="France">
                <rule lifePlusYears="70" note="War-time extensions may be added."/>
            </jurisdiction>
            <jurisdiction code="GA" name="Gabon"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="GB" name="United Kingdom"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="GD" name="Grenada"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="GE" name="Georgia"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="GF" name="French Guiana" see="FR"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="GG" name="Guernsey" see="UK"/>
            <jurisdiction code="GH" name="Ghana"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="GI" name="Gibraltar" see="UK"/>
            <jurisdiction code="GL" name="Greenland" see="DK"/>
            <jurisdiction code="GM" name="Gambia"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="GN" name="Guinea"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="GP" name="Guadeloupe" see="FR"/>
            <jurisdiction code="GQ" name="Equatorial Guinea"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="GR" name="Greece"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="GS" name="South Georgia and the South Sandwich Islands" see="UK"/>
            <jurisdiction code="GT" name="Guatemala"><rule lifePlusYears="75"/></jurisdiction>
            <jurisdiction code="GU" name="Guam" see="US"/>
            <jurisdiction code="GW" name="Guinea-Bissau"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="GY" name="Guyana"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="HK" name="Hong Kong, SAR China"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="HM" name="Heard and Mcdonald Islands" see="AU"/>
            <jurisdiction code="HN" name="Honduras"><rule lifePlusYears="75"/></jurisdiction>
            <jurisdiction code="HR" name="Croatia"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="HT" name="Haiti"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="HU" name="Hungary"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="ID" name="Indonesia"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="IE" name="Ireland"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="IL" name="Israel"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="IM" name="Isle of Man" see="UK"/>
            <jurisdiction code="IN" name="India"><rule lifePlusYears="60"/></jurisdiction>
            <jurisdiction code="IO" name="British Indian Ocean Territory" see="UK"/>
            <jurisdiction code="IQ" name="Iraq"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="IR" name="Iran, Islamic Republic of"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="IS" name="Iceland"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="IT" name="Italy"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="JE" name="Jersey" see="UK"/>
            <jurisdiction code="JM" name="Jamaica"><rule lifePlusYears="95"/></jurisdiction>
            <jurisdiction code="JO" name="Jordan"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="JP" name="Japan"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="KE" name="Kenya"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="KG" name="Kyrgyzstan"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="KH" name="Cambodia"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="KI" name="Kiribati"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="KM" name="Comoros"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="KN" name="Saint Kitts and Nevis"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="KP" name="Korea (North)"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="KR" name="Korea (South)"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="KW" name="Kuwait"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="KY" name="Cayman Islands" see="UK"/>
            <jurisdiction code="KZ" name="Kazakhstan"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="LA" name="Lao PDR"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="LB" name="Lebanon"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="LC" name="Saint Lucia"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="LI" name="Liechtenstein"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="LK" name="Sri Lanka"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="LR" name="Liberia"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="LS" name="Lesotho"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="LT" name="Lithuania"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="LU" name="Luxembourg"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="LV" name="Latvia"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="LY" name="Libya"><rule lifePlusYears="25"/></jurisdiction>
            <jurisdiction code="MA" name="Morocco"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="MC" name="Monaco"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="MD" name="Moldova"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="ME" name="Montenegro"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="MF" name="Saint-Martin" see="FR"/>
            <jurisdiction code="MG" name="Madagascar"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="MH" name="Marshall Islands"><rule lifePlusYears="0"/></jurisdiction>
            <jurisdiction code="MK" name="Macedonia, Republic of"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="ML" name="Mali"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="MM" name="Myanmar"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="MN" name="Mongolia"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="MO" name="Macao, SAR China"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="MP" name="Northern Mariana Islands" see="US"/>
            <jurisdiction code="MQ" name="Martinique" see="FR"/>
            <jurisdiction code="MR" name="Mauritania"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="MS" name="Montserrat" see="UK"/>
            <jurisdiction code="MT" name="Malta"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="MU" name="Mauritius"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="MV" name="Maldives"><rule lifePlusYears="XXX"/></jurisdiction>
            <jurisdiction code="MW" name="Malawi"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="MX" name="Mexico">
                <rule lifePlusYears="100" fromDeathDate="1928-07-23"/>
                <rule lifePlusYears="75" fromDeathDate="1944-01-01"/>
                <rule lifePlusYears="50"/>
            </jurisdiction>
            <jurisdiction code="MY" name="Malaysia"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="MZ" name="Mozambique"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="NA" name="Namibia"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="NC" name="New Caledonia" see="FR"/>
            <jurisdiction code="NE" name="Niger"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="NF" name="Norfolk Island" see="AU"/>
            <jurisdiction code="NG" name="Nigeria"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="NI" name="Nicaragua"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="NL" name="Netherlands"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="NO" name="Norway"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="NP" name="Nepal"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="NR" name="Nauru"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="NU" name="Niue"><rule lifePlusYears="XXX"/></jurisdiction>
            <jurisdiction code="NZ" name="New Zealand"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="OM" name="Oman"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="PA" name="Panama"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="PE" name="Peru"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="PF" name="French Polynesia" see="FR"/>
            <jurisdiction code="PG" name="Papua New Guinea"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="PH" name="Philippines"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="PK" name="Pakistan"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="PL" name="Poland"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="PM" name="Saint Pierre and Miquelon" see="FR"/>
            <jurisdiction code="PN" name="Pitcairn" see="UK"/>
            <jurisdiction code="PR" name="Puerto Rico" see="US"/>
            <jurisdiction code="PS" name="Palestinian Territory"><rule lifePlusYears="XXX"/></jurisdiction>
            <jurisdiction code="PT" name="Portugal"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="PW" name="Palau" see="US"/>
            <jurisdiction code="PY" name="Paraguay"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="QA" name="Qatar"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="RE" name="R&eacute;union" see="FR"/>
            <jurisdiction code="RO" name="Romania"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="RS" name="Serbia"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="RU" name="Russian Federation"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="RW" name="Rwanda"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="SA" name="Saudi Arabia"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="SB" name="Solomon Islands"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="SC" name="Seychelles"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="SD" name="Sudan"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="SE" name="Sweden"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="SG" name="Singapore"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="SH" name="Saint Helena"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="SI" name="Slovenia"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="SJ" name="Svalbard and Jan Mayen Islands" see="NO"/>
            <jurisdiction code="SK" name="Slovakia"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="SL" name="Sierra Leone"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="SM" name="San Marino"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="SN" name="Senegal"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="SO" name="Somalia"><rule lifePlusYears="XXX"/></jurisdiction>
            <jurisdiction code="SR" name="Suriname"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="SS" name="South Sudan"><rule lifePlusYears="XXX"/></jurisdiction>
            <jurisdiction code="ST" name="Sao Tome and Principe"><rule lifePlusYears="XXX"/></jurisdiction>
            <jurisdiction code="SV" name="El Salvador"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="SY" name="Syrian Arab Republic (Syria)"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="SZ" name="Swaziland"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="TC" name="Turks and Caicos Islands" see="UK"/>
            <jurisdiction code="TD" name="Chad"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="TF" name="French Southern Territories" see="FR"/>
            <jurisdiction code="TG" name="Togo"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="TH" name="Thailand"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="TJ" name="Tajikistan"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="TK" name="Tokelau" see="NZ"/>
            <jurisdiction code="TL" name="Timor-Leste"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="TM" name="Turkmenistan"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="TN" name="Tunisia"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="TO" name="Tonga"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="TR" name="Turkey"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="TT" name="Trinidad and Tobago"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="TV" name="Tuvalu"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="TW" name="Taiwan, Republic of China"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="TZ" name="Tanzania, United Republic of"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="UA" name="Ukraine"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="UG" name="Uganda"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="UM" name="US Minor Outlying Islands" see="US"/>
            <jurisdiction code="US" name="United States" shortestTerm="no">
                <rule lifePlusYears="70" fromPublicationDate="1978-01-01"/>
                <rule publicationPlusYears="95" fromPublicationDate="1923-01-01"/>
                <rule publicationPlusYears="75"/>
            </jurisdiction>
            <jurisdiction code="UY" name="Uruguay"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="UZ" name="Uzbekistan"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="VA" name="Holy See (Vatican City State)"><rule lifePlusYears="70"/></jurisdiction>
            <jurisdiction code="VC" name="Saint Vincent and Grenadines"><rule lifePlusYears="75"/></jurisdiction>
            <jurisdiction code="VE" name="Venezuela (Bolivarian Republic)"><rule lifePlusYears="60"/></jurisdiction>
            <jurisdiction code="VG" name="British Virgin Islands" see="UK"/>
            <jurisdiction code="VI" name="Virgin Islands, US" see="US"/>
            <jurisdiction code="VN" name="Viet Nam"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="VU" name="Vanuatu"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="WF" name="Wallis and Futuna Islands" see="FR"/>
            <jurisdiction code="WS" name="Samoa"><rule lifePlusYears="75"/></jurisdiction>
            <jurisdiction code="YE" name="Yemen"><rule lifePlusYears="30"/></jurisdiction>
            <jurisdiction code="YT" name="Mayotte" see="FR"/>
            <jurisdiction code="ZA" name="South Africa"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="ZM" name="Zambia"><rule lifePlusYears="50"/></jurisdiction>
            <jurisdiction code="ZW" name="Zimbabwe"><rule lifePlusYears="50"/></jurisdiction>
        </jurisdictions>
    </xsl:variable>

</xsl:stylesheet>

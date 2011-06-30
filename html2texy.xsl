<?xml version="1.0" encoding="utf-8"?>
<!--
:mode=xsl:folding=explicit:collapseFolds=1:

Copyright (C) 2007 Jakub Roztocil <jakub@roztocil.name>

html2texy! (v0.2) - HTML/XHTML to Texy2 convertor

html2texy homepage: http://www.webkitchen.cz/lab/html2texy/
Texy! homepage: http://www.texy.info/

{{{ Licence

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

}}}



-->
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:func="http://exslt.org/functions"
		xmlns:f="http://ns.webkitchen.cz/functions"
		xmlns:php="http://php.net/xsl"
		extension-element-prefixes="func"
		exclude-result-prefixes="func f">

	<xsl:output method="text" encoding="utf-8" />


	<!--{{{  Parameters -->
	<!-- TODO: whitespace -->
	<xsl:param name="ignore-all-divs" select="false()" />
	<xsl:param name="ignore-empty-divs" select="false()" />
	<!--}}}-->


	<xsl:template match="/ | *">
		<xsl:apply-templates select="*" />
	</xsl:template>

	<!--{{{ Helpers -->

	<func:function name="f:repeat">
		<xsl:param name="string"/>
		<xsl:param name="count"/>
		<func:result>
			<xsl:call-template name="repeat">
				<xsl:with-param name="string" select="$string"/>
				<xsl:with-param name="count" select="$count"/>
			</xsl:call-template>
		</func:result>
	</func:function>

	<func:function name="f:is-inline">
		<xsl:param name="element"/>
		<func:result>
			<xsl:variable name="n" select="local-name($element)"/>
			<xsl:value-of select="number(
				   $n = 'a'
				or $n = 'b'
				or $n = 'br'
				or $n = 'i'
				or $n = 'img'
				or $n = 'u'
				or $n = 'em'
				or $n = 'strong'
				or $n = 'sup'
				or $n = 'sub'
				or $n = 'code'
				or $n = 'span'
				or $n = 'abbr'
				or $n = 'acronym'
			)"/>
		</func:result>
	</func:function>

    <!-- bug in libxslt 1.1.20
	<func:function name="f:is-block">
		<xsl:param name="element"/>
		<func:result>
			<xsl:value-of select="not(f:is-inline($element))"/>
		</func:result>
	</func:function>
	 -->

	<xsl:template name="repeat">
		<xsl:param name="string"/>
		<xsl:param name="count"/>
		<xsl:param name="current" select="1"/>
		<xsl:if test="$current &lt;= $count">
			<xsl:value-of select="$string"/>
		</xsl:if>
		<xsl:if test="$current &lt; $count">
			<xsl:call-template name="repeat">
				<xsl:with-param name="string" select="$string"/>
				<xsl:with-param name="count" select="$count"/>
				<xsl:with-param name="current" select="$current + 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!--}}}-->

	<!--{{{ Misc -->

	<xsl:template match="
		html | body | bdo | big | button |
		center | col | colgroup | dfn |
		font | form | fieldset | label |
		legend | small | span | u
	">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="
		head |
		a[@name] | area | applet |
		frame | frameset | iframe |
		input | isindex |
		link |
		map |
		noframes | noscript | object |
		script |
		textarea
	" />

	<xsl:template match="p | address">
		<xsl:text>&#10;</xsl:text>
		<xsl:apply-templates  />
		<xsl:apply-templates select="." mode="modifiers"/>
		<xsl:text>&#10;&#10;</xsl:text>
	</xsl:template>



	<xsl:template match="div">
		<xsl:variable name="has-childern" select="* or text()[normalize-space(.) != '']"/>
		<xsl:choose>
			<xsl:when test="not($ignore-all-divs) and ($has-childern or (not(*) and not($ignore-empty-divs)))">
				<xsl:text>&#10;</xsl:text>
				<xsl:text>/---div </xsl:text>
				<xsl:apply-templates select="." mode="modifiers"/>
				<xsl:text>&#10;&#10;</xsl:text>
				<xsl:apply-templates />
				<xsl:text>&#10;</xsl:text>
				<xsl:text>\---</xsl:text>
				<xsl:text>&#10;&#10;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--}}}-->

	<!--{{{ Modifiers -->
	<!-- TODO: style, align -->
	<xsl:template match="*" mode="modifiers">
		<xsl:param name="ignore-title" select="false()" />
		<xsl:param name="full-line" select="false()" />
		<xsl:if test="@*[not(
			   name() = 'style'
			or name() = 'colspan'
			or name() = 'rowspan'
			or name() = 'href'
			or name() = 'alt'
			or name() = 'cite'
			or name() = 'src'
			or name() = 'width'
			or name() = 'height'

			)]">
			<xsl:if test="not($full-line)">
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:text>.</xsl:text>
			<xsl:if test="@class or @id">
				<xsl:text>[</xsl:text>
				<xsl:if test="@class">
					<xsl:apply-templates select="@class"/>
				</xsl:if>
				<xsl:if test="@class and @id">
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:if test="@id">
					<xsl:text>#</xsl:text>
					<xsl:apply-templates select="@id" />
				</xsl:if>
				<xsl:text>]</xsl:text>
			</xsl:if>
			<xsl:if test="not($ignore-title) and (@title or @alt)">
				<xsl:text>(</xsl:text>
				<xsl:choose>
					<xsl:when test="@alt">
						<xsl:apply-templates select="@alt" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="@title" />
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>)</xsl:text>
			</xsl:if>
			<xsl:variable name="attrs" select="@*[not(
			   name() = 'title'
			or name() = 'class'
			or name() = 'id'
			or name() = 'title'
			or name() = 'style'
			or name() = 'colspan'
			or name() = 'rowspan'
			or name() = 'href'
			or name() = 'alt'
			or name() = 'cite'
			or name() = 'src'
			or name() = 'width'
			or name() = 'height'

			)]"/>
			<xsl:if test="$attrs">
				<xsl:text>{</xsl:text>
				<xsl:for-each select="$attrs">
					<xsl:value-of select="concat(name(), ':')"/>
					<xsl:apply-templates select="."/>
					<xsl:if test="position() != last()">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:for-each>
				<xsl:text>}</xsl:text>
			</xsl:if>
			<xsl:if test="$full-line">
				<xsl:text>&#10;</xsl:text>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<!--}}}-->

	<!--{{{ Text -->
	<!-- TODO: whitespaces -->
	<xsl:template match="@*">
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>

	<xsl:template match="text()">
		<xsl:variable name="text" select="php:functionString('preg_replace', '/\s+/', ' ', .)"/>
		<xsl:variable name="following" select="following-sibling::node()[1]"/>
		<xsl:variable name="preceding" select="preceding-sibling::node()[1]"/>
		<xsl:choose>
			<xsl:when test="(not($preceding) or $preceding[self::br]) and (not($following) or $following[self::br])">
				<xsl:value-of select="normalize-space($text)"/>
			</xsl:when>
			<xsl:when test="not($following) or $following[self::br]">
				<xsl:value-of select="php:functionString('rtrim', $text)"/>
			</xsl:when>
			<xsl:when test="not($preceding) or $preceding[self::br]">
				<xsl:value-of select="php:functionString('ltrim', $text)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- skip whitespaces between block elements -->
	<xsl:template match="text()[
			normalize-space(.) = ''
			and preceding-sibling::*
			and following-sibling::*
			and f:is-inline(preceding-sibling::*[1]) = 0
			and f:is-inline(following-sibling::*[1]) = 0
		]" />

	<!--}}}-->

	<!--{{{ Citations-->

	<!-- TODO: inline headers -->
	<!-- TODO: free text -->
	<xsl:template match="blockquote">
		<xsl:apply-templates />
		<xsl:variable name="indent" select="f:repeat('&gt; ', count(ancestor-or-self::blockquote))"/>
		<xsl:variable name="mods">
			<xsl:apply-templates select="." mode="modifiers"/>
		</xsl:variable>
		<xsl:if test="$mods">
			<xsl:value-of select="$indent"/>
			<xsl:value-of select="$mods"/>
		</xsl:if>
		<xsl:if test="@cite">
			<xsl:text>&#10;</xsl:text>
			<xsl:value-of select="substring($indent, 1, string-length($indent) - 1)"/>
			<xsl:text>:</xsl:text>
			<xsl:value-of select="@cite"/>
		</xsl:if>
		<xsl:text>&#10;</xsl:text>
		<xsl:if test="not(ancestor::blockquote)">
			<xsl:text>&#10;</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="blockquote//p | blockquote//address">
		<xsl:variable name="indent" select="f:repeat('&gt; ', count(ancestor::blockquote))"/>
		<xsl:value-of select="$indent"/>
		<xsl:apply-templates  />
		<xsl:apply-templates select="."	 mode="modifiers"/>
		<xsl:text>&#10;</xsl:text>
		<xsl:value-of select="$indent"/>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>

	<xsl:template match="q">
		<xsl:text>&gt;&gt;</xsl:text>
		<xsl:apply-templates />
		<xsl:apply-templates select="." mode="modifiers"/>
		<xsl:text>&lt;&lt;</xsl:text>
		<xsl:if test="@cite">
			<xsl:text>:</xsl:text>
			<xsl:value-of select="@cite"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="cite">
		<xsl:text>~~</xsl:text>
		<xsl:apply-templates />
		<xsl:apply-templates select="." mode="modifiers"/>
		<xsl:text>~~</xsl:text>
	</xsl:template>

	<!--}}}-->

	<!--{{{ Emphasis-->

	<xsl:template match="em | i">
		<xsl:text>*</xsl:text>
		<xsl:apply-templates />
		<xsl:apply-templates select="." mode="modifiers"/>
		<xsl:text>*</xsl:text>
	</xsl:template>

	<xsl:template match="strong | b">
		<xsl:text>**</xsl:text>
		<xsl:apply-templates />
		<xsl:apply-templates select="." mode="modifiers"/>
		<xsl:text>**</xsl:text>
	</xsl:template>

	<xsl:template match="*[self::strong or self::b][em or i]">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="*[self::strong or self::b]/*[self::em or self::i]">
		<xsl:text>***</xsl:text>
		<xsl:apply-templates />
		<xsl:apply-templates select="." mode="modifiers"/>
		<xsl:text>***</xsl:text>
	</xsl:template>

	<!--}}}-->

	<!--{{{ Acronyms -->
	<xsl:template match="abbr | acronym">
		<xsl:text>"</xsl:text>
		<xsl:apply-templates />
		<xsl:text>"</xsl:text>
		<xsl:value-of select="concat('((', @title, '))')"/>
		<xsl:apply-templates select="." mode="modifiers">
			<xsl:with-param name="ignore-title" select="true()"/>
		</xsl:apply-templates>
	</xsl:template>
	<!--}}}-->

	<!--{{{ Tables -->

	<xsl:template match="tbody | thead">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="table">
		<xsl:text>&#10;</xsl:text>
		<xsl:apply-templates select="." mode="modifiers">
			<xsl:with-param name="full-line" select="true()"/>
		</xsl:apply-templates>
		<xsl:apply-templates />
		<xsl:text>&#10;&#10;</xsl:text>
	</xsl:template>

	<xsl:template match="caption">
		<xsl:text>|==== </xsl:text>
		<xsl:apply-templates />
		<xsl:apply-templates select="." mode="modifiers"/>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>

	<xsl:template match="tr">
		<xsl:apply-templates />
		<xsl:apply-templates select="." mode="modifiers" />
		<xsl:text>&#10;</xsl:text>
	</xsl:template>

	<!-- TODO: @rowspan -->
	<xsl:template match="th | td">
		<xsl:text>|</xsl:text>
		<xsl:if test="self::th">*</xsl:if>
		<xsl:text> </xsl:text>
		<xsl:apply-templates />
		<xsl:apply-templates select="." mode="modifiers" />
		<xsl:text> </xsl:text>
		<xsl:if test="@colspan">
			<xsl:variable name="pipes-count">
				<xsl:choose>
					<xsl:when test="following-sibling::th or following-sibling::td">
						<xsl:value-of select="@colspan - 1"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@colspan"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:value-of select="f:repeat('|', $pipes-count)"/>
		</xsl:if>
	</xsl:template>


	<!--}}}-->

	<!--{{{ Other inline-->

	<xsl:template match="br">
		<xsl:text>&#10;</xsl:text>
		<xsl:value-of select="f:repeat('&gt; ', count(ancestor::blockquote))"/>
		<xsl:text> </xsl:text>
	</xsl:template>

	<xsl:template match="hr">
		<xsl:text>&#10;&#10;</xsl:text>
		<xsl:text>--------</xsl:text>
		<xsl:apply-templates select="." mode="modifiers" />
		<xsl:text>&#10;&#10;</xsl:text>
	</xsl:template>

	<xsl:template match="a">
		<xsl:text>"</xsl:text>
		<xsl:apply-templates />
		<xsl:apply-templates select="." mode="modifiers" />
		<xsl:text>":[</xsl:text>
		<xsl:value-of select="@href"/>
		<xsl:text>]</xsl:text>
	</xsl:template>

	<xsl:template match="sup">
		<xsl:text>^^</xsl:text>
		<xsl:apply-templates />
		<xsl:apply-templates select="." mode="modifiers" />
		<xsl:text>^^</xsl:text>
	</xsl:template>

	<xsl:template match="sub">
		<xsl:text>__</xsl:text>
		<xsl:apply-templates/>
		<xsl:apply-templates select="." mode="modifiers" />
		<xsl:text>__</xsl:text>
	</xsl:template>

	<xsl:template match="img">
		<xsl:text>[* </xsl:text>
		<xsl:value-of select="@src"/>
		<xsl:if test="@width and @height">
			<xsl:value-of select="concat(' ', @width, 'x', @height)"/>
		</xsl:if>
		<xsl:apply-templates select="." mode="modifiers" />
		<xsl:text> </xsl:text>
		<xsl:choose>
			<xsl:when test="@class = 'left'">
				<xsl:text>&lt;</xsl:text>
			</xsl:when>
			<xsl:when test="@class = 'right'">
				<xsl:text>&lt;</xsl:text>
			</xsl:when>
			<xsl:otherwise>*</xsl:otherwise>
		</xsl:choose>
		<xsl:text>]</xsl:text>
	</xsl:template>

	<xsl:template match="del | strike | s">
		<xsl:text>--</xsl:text>
		<xsl:apply-templates/>
		<xsl:apply-templates select="." mode="modifiers" />
		<xsl:text>--</xsl:text>
	</xsl:template>

	<xsl:template match="ins">
		<xsl:text>++</xsl:text>
		<xsl:apply-templates/>
		<xsl:apply-templates select="." mode="modifiers" />
		<xsl:text>++</xsl:text>
	</xsl:template>

	<!--}}}-->

	<!--{{{ Headings -->
	<xsl:template match="h1 | h2 | h3 | h4">
		<xsl:apply-templates />
		<xsl:apply-templates select="." mode="modifiers" />
		<xsl:variable name="char">
			<xsl:choose>
				<xsl:when test="self::h1">#</xsl:when>
				<xsl:when test="self::h2">*</xsl:when>
				<xsl:when test="self::h3">=</xsl:when>
				<xsl:when test="self::h4">-</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:text>&#10;</xsl:text>
		<xsl:value-of select="f:repeat($char, string-length(.))"/>
		<xsl:text>&#10;&#10;</xsl:text>
	</xsl:template>
	<!--}}}-->

	<!--{{{ Lists -->

	<!-- TODO: nested DLs -->

	<xsl:template match="ul | ol | menu | dir">
		<xsl:apply-templates select="." mode="modifiers">
			<xsl:with-param name="full-line" select="true()"/>
		</xsl:apply-templates>
		<xsl:apply-templates />

	</xsl:template>

	<xsl:template match="dl | *[self::ol or self::ul or self::menu or self::dir][not(parent::li)]">
		<xsl:apply-templates select="." mode="modifiers">
			<xsl:with-param name="full-line" select="true()"/>
		</xsl:apply-templates>
		<xsl:apply-templates />
		<xsl:text>&#10;&#10;</xsl:text>
	</xsl:template>

	<xsl:template match="li">
		<xsl:variable name="deep" select="count(ancestor::*[self::ol or self::ul or self::menu or self::dir])"/>
		<xsl:if test="$deep > 1">
			<xsl:value-of select="f:repeat('  ', $deep - 1)"/>
		</xsl:if>
		<xsl:apply-templates select="." mode="numbering">
			<xsl:with-param name="pos" select="count(preceding-sibling::li) + 1"/>
		</xsl:apply-templates>
		<xsl:text> </xsl:text>
		<xsl:apply-templates select="node()[not(self::ul or self::ol or self::menu or self::dir)]"/>
		<xsl:apply-templates select="." mode="modifiers" />
		<xsl:text>&#10;</xsl:text>
		<xsl:apply-templates select="ul | ol | menu | dir" />
	</xsl:template>

	<xsl:template match="li" mode="numbering">
		<xsl:param name="pos"/>
		<xsl:choose>
			<xsl:when test="not(contains(@style, 'list-style-type:')) and parent::*[self::ul or self::menu or self::dir]">+</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="styled-parent" select="ancestor-or-self::*[position() = 1 or position() = 2][contains(@style, 'list-style-type:')][1]"/>
				<xsl:variable name="style" select="$styled-parent/@style"/>
				<xsl:variable name="format">
					<xsl:choose>
						<xsl:when test="contains($style, 'lower-roman')">i</xsl:when>
						<xsl:when test="contains($style, 'upper-roman')">I</xsl:when>
						<xsl:when test="contains($style, 'lower-alpha')">a</xsl:when>
						<xsl:when test="contains($style, 'upper-alpha')">A</xsl:when>
						<xsl:otherwise>1</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:number value="$pos" format="{$format}" />
				<xsl:text>)</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="dt">
		<xsl:apply-templates />
		<xsl:apply-templates select="." mode="modifiers"/>
		<xsl:text>:&#10;</xsl:text>
	</xsl:template>

	<xsl:template match="dd">
		<xsl:text>    - </xsl:text>
		<xsl:apply-templates />
		<xsl:apply-templates select="." mode="modifiers"/>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>

	<!--}}}-->

	<!--{{{ Code -->
	<xsl:template match="pre">
		<xsl:text>/---code</xsl:text>
		<!--{{{  geshi -->
		<xsl:if test="@class='actionscript'
					  or @class='actionscript-french'
					  or @class='ada'
					  or @class='apache'
					  or @class='applescript'
					  or @class='asm'
					  or @class='asp'
					  or @class='autoit'
					  or @class='bash'
					  or @class='blitzbasic'
					  or @class='bnf'
					  or @class='c'
					  or @class='c_mac'
					  or @class='caddcl'
					  or @class='cadlisp'
					  or @class='cfdg'
					  or @class='cfm'
					  or @class='cpp'
					  or @class='cpp-qt'
					  or @class='csharp'
					  or @class='css'
					  or @class='d'
					  or @class='delphi'
					  or @class='diff'
					  or @class='div'
					  or @class='dos'
					  or @class='eiffel'
					  or @class='fortran'
					  or @class='freebasic'
					  or @class='gml'
					  or @class='groovy'
					  or @class='html4strict'
					  or @class='idl'
					  or @class='inno'
					  or @class='io'
					  or @class='java'
					  or @class='java5'
					  or @class='javascript'
					  or @class='latex'
					  or @class='lisp'
					  or @class='lua'
					  or @class='matlab'
					  or @class='mirc'
					  or @class='mpasm'
					  or @class='mysql'
					  or @class='nsis'
					  or @class='objc'
					  or @class='ocaml'
					  or @class='ocaml-brief'
					  or @class='oobas'
					  or @class='oracle8'
					  or @class='pascal'
					  or @class='perl'
					  or @class='php'
					  or @class='php-brief'
					  or @class='plsql'
					  or @class='python'
					  or @class='qbasic'
					  or @class='reg'
					  or @class='robots'
					  or @class='ruby'
					  or @class='sas'
					  or @class='scheme'
					  or @class='sdlbasic'
					  or @class='smalltalk'
					  or @class='smarty'
					  or @class='sql'
					  or @class='tcl'
					  or @class='text'
					  or @class='thinbasic'
					  or @class='tsql'
					  or @class='vb'
					  or @class='vbnet'
					  or @class='vhdl'
					  or @class='visualfoxpro'
					  or @class='winbatch'
					  or @class='xml'
					  or @class='z80'">
					  <xsl:text> </xsl:text>
					  <xsl:value-of select="@class"/>
		</xsl:if>
		<!--}}}-->
		<xsl:text>&#10;</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>&#10;</xsl:text>
		<xsl:text>\---</xsl:text>
		<xsl:text>&#10;&#10;</xsl:text>
	</xsl:template>

	<xsl:template match="code | kbd | samp | tt | var">
		<xsl:text>`</xsl:text>
		<xsl:apply-templates />
		<xsl:text>`</xsl:text>
	</xsl:template>

	<!--}}}-->

</xsl:stylesheet>

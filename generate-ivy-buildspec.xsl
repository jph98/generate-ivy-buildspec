<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:param name="confs"    select="/ivy-report/info/@confs"/>
<xsl:param name="extension"    select="'xml'"/>

<xsl:variable name="myorg"    select="/ivy-report/info/@organisation"/>
<xsl:variable name="mymod"    select="/ivy-report/info/@module"/>
<xsl:variable name="myconf"   select="/ivy-report/info/@conf"/>

<xsl:variable name="modules"    select="/ivy-report/dependencies/module"/>
<xsl:variable name="conflicts"    select="$modules[count(revision) > 1]"/>

<xsl:variable name="revisions"  select="$modules/revision"/>
<xsl:variable name="evicteds"   select="$revisions[@evicted]"/>
<xsl:variable name="downloadeds"   select="$revisions[@downloaded='true']"/>
<xsl:variable name="searcheds"   select="$revisions[@searched='true']"/>
<xsl:variable name="errors"   select="$revisions[@error]"/>

<xsl:variable name="artifacts"   select="$revisions/artifacts/artifact"/>
<xsl:variable name="cacheartifacts" select="$artifacts[@status='no']"/>
<xsl:variable name="dlartifacts" select="$artifacts[@status='successful']"/>
<xsl:variable name="faileds" select="$artifacts[@status='failed']"/>
<xsl:variable name="artifactsok" select="$artifacts[@status!='failed']"/>

<xsl:template name="calling">
    <xsl:param name="org" />
    <xsl:param name="mod" />
    <xsl:param name="rev" />

    <xsl:if test="count($modules/revision/caller[(@organisation=$org and @name=$mod) and @callerrev=$rev]) = 0">
    <table><tr><td>
    No dependency
    </td></tr></table>
    </xsl:if>

    <xsl:if test="count($modules/revision/caller[(@organisation=$org and @name=$mod) and @callerrev=$rev]) > 0">

    <table class="deps">
      <thead>
      <tr>
        <th>Module</th>
        <th>Version</th>
	<th>Size</th>
        <th>Licenses</th>
        <th></th>
      </tr>
      </thead>
      <tbody>
        <xsl:for-each select="$modules/revision/caller[(@organisation=$org and @name=$mod) and @callerrev=$rev]">

          <xsl:call-template name="called">
            <xsl:with-param name="callstack"     select="concat($org, string('/'), $mod)"/>
            <xsl:with-param name="indent"        select="string('')"/>
            <xsl:with-param name="revision"      select=".."/>
          </xsl:call-template>
        </xsl:for-each>   
      </tbody>
    </table>

    </xsl:if>
</xsl:template>

<xsl:template name="called">
    <xsl:param name="callstack"/>
    <xsl:param name="indent"/>
    <xsl:param name="revision"/>

    <xsl:param name="organisation" select="$revision/../@organisation"/>
    <xsl:param name="module" select="$revision/../@name"/>
    <xsl:param name="rev" select="$revision/@name"/>
    <xsl:param name="resolver" select="$revision/@resolver"/>
    <xsl:param name="isdefault" select="$revision/@default"/>
    <xsl:param name="status" select="$revision/@status"/>

<xsl:if test="not($revision/@evicted)">

    <tr>
    <td>
       <xsl:element name="a">
         <xsl:attribute name="href">#<xsl:value-of select="$organisation"/>-<xsl:value-of select="$module"/></xsl:attribute>
         <xsl:value-of select="concat($indent, ' ')"/>
         <xsl:value-of select="$module"/>
         by
         <xsl:value-of select="$organisation"/>
       </xsl:element>
    </td>
    <td>
       <xsl:element name="a">
         <xsl:attribute name="href">#<xsl:value-of select="$organisation"/>-<xsl:value-of select="$module"/>-<xsl:value-of select="$rev"/></xsl:attribute>
         <xsl:value-of select="$rev"/>
       </xsl:element>
    </td>
    <td align="center">
      <xsl:value-of select="round(sum($revision/artifacts/artifact/@size) div 1024)"/> kB
    </td>
    <td align="center">
      <xsl:call-template name="licenses">
        <xsl:with-param name="revision"      select="$revision"/>
      </xsl:call-template>
    </td>
    </tr>
    <xsl:if test="not($revision/@evicted)">
    <xsl:if test="not(contains($callstack, concat($organisation, string('/'), $module)))">
    <xsl:for-each select="$modules/revision/caller[(@organisation=$organisation and @name=$module) and @callerrev=$rev]">
          <xsl:call-template name="called">
            <xsl:with-param name="callstack"     select="concat($callstack, string('#'), $organisation, string('/'), $module)"/>
            <xsl:with-param name="indent"        select="concat($indent, string('---'))"/>
            <xsl:with-param name="revision"      select=".."/>
          </xsl:call-template>
    </xsl:for-each>   
    </xsl:if>
    </xsl:if>
</xsl:if>
</xsl:template>

<xsl:template name="licenses">
      <xsl:param name="revision"/>
      <xsl:for-each select="$revision/license">
      	<span style="padding-right:3px;">
      	<xsl:if test="@url">
  	        <xsl:element name="a">
  	            <xsl:attribute name="href"><xsl:value-of select="@url"/></xsl:attribute>
  		    	<xsl:value-of select="@name"/>
  	        </xsl:element>
      	</xsl:if>
      	<xsl:if test="not(@url)">
  		    	<xsl:value-of select="@name"/>
      	</xsl:if>
      	</span>
      </xsl:for-each>
</xsl:template>

<xsl:template name="icons">
    <xsl:param name="revision"/>
    <xsl:if test="$revision/@searched = 'true'">
         <img src="http://ant.apache.org/ivy/images/searched.gif" alt="searched" title="required a search in repository"/>
    </xsl:if>
    <xsl:if test="$revision/@downloaded = 'true'">
         <img src="http://ant.apache.org/ivy/images/downloaded.gif" alt="downloaded" title="downloaded from repository"/>
    </xsl:if>
    <xsl:if test="$revision/@evicted">
        <xsl:element name="img">
            <xsl:attribute name="src">http://ant.apache.org/ivy/images/evicted.gif</xsl:attribute>
            <xsl:attribute name="alt">evicted</xsl:attribute>
            <xsl:attribute name="title">evicted by <xsl:for-each select="$revision/evicted-by"><xsl:value-of select="@rev"/> </xsl:for-each></xsl:attribute>
        </xsl:element>
    </xsl:if>
    <xsl:if test="$revision/@error">
        <xsl:element name="img">
            <xsl:attribute name="src">http://ant.apache.org/ivy/images/error.gif</xsl:attribute>
            <xsl:attribute name="alt">error</xsl:attribute>
            <xsl:attribute name="title">error: <xsl:value-of select="$revision/@error"/></xsl:attribute>
        </xsl:element>
    </xsl:if>
</xsl:template>

<xsl:template name="error">
    <xsl:param name="organisation"/>
    <xsl:param name="module"/>
    <xsl:param name="revision"/>
    <xsl:param name="error"/>
    <tr>
    <td>
       <xsl:element name="a">
         <xsl:attribute name="href">#<xsl:value-of select="$organisation"/>-<xsl:value-of select="$module"/></xsl:attribute>
         <xsl:value-of select="$module"/>
         by
         <xsl:value-of select="$organisation"/>
       </xsl:element>
    </td>
    <td>
       <xsl:element name="a">
         <xsl:attribute name="href">#<xsl:value-of select="$organisation"/>-<xsl:value-of select="$module"/>-<xsl:value-of select="$revision"/></xsl:attribute>
         <xsl:value-of select="$revision"/>
       </xsl:element>
    </td>
    <td>
         <xsl:value-of select="$error"/>
    </td>
    </tr>
</xsl:template>

<xsl:template name="confs">
    <xsl:param name="configurations"/>
    
    <xsl:if test="contains($configurations, ',')">
      <xsl:call-template name="conf">
        <xsl:with-param name="conf" select="normalize-space(substring-before($configurations,','))"/>
      </xsl:call-template>
      <xsl:call-template name="confs">
        <xsl:with-param name="configurations" select="substring-after($configurations,',')"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="not(contains($configurations, ','))">
      <xsl:call-template name="conf">
        <xsl:with-param name="conf" select="normalize-space($configurations)"/>
      </xsl:call-template>
    </xsl:if>
</xsl:template>

<xsl:template name="conf">
    <xsl:param name="conf"/>
    
     <li>
       <xsl:element name="a">
         <xsl:if test="$conf = $myconf">
           <xsl:attribute name="class">active</xsl:attribute>
         </xsl:if>
         <xsl:attribute name="href"><xsl:value-of select="$myorg"/>-<xsl:value-of select="$mymod"/>-<xsl:value-of select="$conf"/>.<xsl:value-of select="$extension"/></xsl:attribute>
         <xsl:value-of select="$conf"/>
       </xsl:element>
     </li>
</xsl:template>

<xsl:template name="date">
    <xsl:param name="date"/>
    
    <xsl:value-of select="substring($date,1,4)"/>-<xsl:value-of select="substring($date,5,2)"/>-<xsl:value-of select="substring($date,7,2)"/>
    <xsl:value-of select="' '"/>
    <xsl:value-of select="substring($date,9,2)"/>:<xsl:value-of select="substring($date,11,2)"/>:<xsl:value-of select="substring($date,13)"/>
</xsl:template>


<xsl:template match="/ivy-report">

  <html>
  <head>
    <title>Ivy report :: <xsl:value-of select="info/@module"/> by <xsl:value-of select="info/@organisation"/> :: <xsl:value-of select="info/@conf"/></title>
    <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1" />
    <meta http-equiv="content-language" content="en" />
    <meta name="robots" content="index,follow" />
    <link rel="stylesheet" type="text/css" href="ivy-report.css" /> 
  </head>

  <body>

    <h1>
      <xsl:element name="a">
        <xsl:attribute name="name"><xsl:value-of select="info/@organisation"/>-<xsl:value-of select="info/@module"/></xsl:attribute>
      </xsl:element>
        <span id="module">
    	        <xsl:value-of select="info/@module"/>
        </span> 
        by 
        <span id="organisation">
    	        <xsl:value-of select="info/@organisation"/>
        </span>
    </h1>
  
    <div id="content">
    <h2>Build Spec Dependency Tree</h2>
	<p>The following tree details each of the dependencies and their relationships to each other</p>
        <table class="header">
          <tr><td class="title">Artifacts</td><td class="value"><xsl:value-of select="count($artifacts)"/> 
(<xsl:value-of select="round(sum($artifacts/@size) div 1024)"/> kB)</td></tr>
        </table>    

        <xsl:call-template name="calling">
          <xsl:with-param name="org" select="info/@organisation"/>
          <xsl:with-param name="mod" select="info/@module"/>
          <xsl:with-param name="rev" select="info/@revision"/>
        </xsl:call-template>

    <h2>Build Spec Components</h2>    
    <p>The following components form a part of this build specification</p>
    <xsl:for-each select="$modules">

    <h3>
      <xsl:element name="a">
         <xsl:attribute name="name"><xsl:value-of select="@organisation"/>-<xsl:value-of select="@name"/></xsl:attribute>
      </xsl:element>
      <xsl:value-of select="@name"/> by <xsl:value-of select="@organisation"/>
    </h3>    

      <xsl:for-each select="revision">

        <xsl:if test="not(@evicted)">
        
        <h4>
          <xsl:element name="a">
             <xsl:attribute name="name"><xsl:value-of select="../@organisation"/>-<xsl:value-of select="../@name"/>-<xsl:value-of select="@name"/></xsl:attribute>
          </xsl:element>
           Version: <xsl:value-of select="@name"/>
          <span style="padding-left:15px;">
          <xsl:call-template name="icons">
            <xsl:with-param name="revision"      select="."/>
          </xsl:call-template>
          </span>
        </h4>

        <table class="header">
          <xsl:if test="@homepage">
            <tr><td class="title">Home Page</td><td class="value">
              <xsl:element name="a">
    	            <xsl:attribute name="href"><xsl:value-of select="@homepage"/></xsl:attribute>
    		    	<xsl:value-of select="@homepage"/>
    	        </xsl:element></td>
            </tr>  	        
        	</xsl:if>
          <tr><td class="title">Size</td><td class="value"><xsl:value-of select="round(sum(artifacts/artifact/@size) div 1024)"/> kB</td></tr>
        	<xsl:if test="count(license) > 0">
            <tr><td class="title">Licenses</td><td class="value">
			      <xsl:call-template name="licenses">
			        <xsl:with-param name="revision"      select="."/>
			      </xsl:call-template>
            </td></tr>  	        
          </xsl:if>
        </table>
        
        </xsl:if>

      </xsl:for-each>    

    </xsl:for-each>
    </div>
  </body>
  </html>
</xsl:template>

</xsl:stylesheet>


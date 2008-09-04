<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.browsercms.com/tags-blocks" prefix="block"%>
<%@ taglib uri="http://www.browsercms.com/tags-pages" prefix="page"%>
<%@ taglib uri="http://www.browsercms.com/cms/core" prefix="cms"%>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-logic" prefix="logic"%>
<%@ taglib tagdir="/WEB-INF/components" prefix="cm" %>
<%@ page import="com.browsercms.security.Permissions"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>${currentPage.name} | Alliance for Microbicide Development</title>
<link href="/site/styles.css" rel="stylesheet" type="text/css" />
<cms:head/>

</head>
<body <c:if test="${currentPage.name=='Home'}">class="home"</c:if><logic:present role="<%= Permissions.CONTENT_EDITOR %>">style="background-position:0px 128px"</logic:present>>
<page:toolbar/>
<div style="display:none"><a name="top" href="#content">skip to content</a></div>
<table class="wrapper" cellspacing="0">
  <tr>
    <td class="leftborder"><img src="/site/images/bg_frame_left.jpg" alt="" width="45" height="800" /></td>
    <td class="site">
    	<table cellspacing="0" <c:if test="${currentPage.template.name=='Subpage'}">class="bgsubpage"</c:if> <c:if test="${currentPage.template.name=='Subpage (No callout)'}">class="bgsubpage_nocallout"</c:if>>
        <tr>
          <td colspan="3" width="928"><div style="float:left"><a href="/"><img src="/site/images/l_microbicide.gif" alt="Alliance for Microbicide Development" border="0" width="472" height="130" /></a></div>
           <div class="search">
           <form action="/cs/search_results" method="get">
             <input type="hidden" name="indexId" value="default"/>
             <input type="hidden" name="hitsStart" value="1"/>
              <table cellspacing="3" cellpadding="0" width="450">
				  <tr>
					<td colspan="2">Enter your search criteria below&nbsp;</td>
				  </tr>
				  <tr>
					<td width="280"><div style="text-align:right;padding:2px 0px"><label for="search"><img src="/site/images/t_search.gif" alt="Search" width="60" height="18" /></label>&nbsp;</div></td>
					<td width="164"><div style="text-align:right;padding:2px 0px"><input id="search" name="query" type="text" style="border:1px solid #aa451c;color:#666;font-size:11px;padding:1px;margin:0;height:15px;width:160px" /></div></td>
				  </tr>
				  <tr>
					<td colspan="2"><div style="text-align:right;padding:1px 0px"><input alt="Search" name="search" type="image" src="/site/images/b_search.gif" /></div></td>
				  </tr>
				  <tr>
					<td colspan="2"><div style="text-align:right;padding:0px"><a href="/cs/advanced_search" style="font-size:9px">advanced search</a></div></td>
				  </tr>
				  <tr>
					<td colspan="2"><div class="uninav" style="margin-top:7px"><a href="https://secure.microbicide.org/DesktopDefault.aspx" target="_blank">MRDD</a> &nbsp;|&nbsp; <a href="https://www.browserevents.com/member_application/apply/3">Subscribe</a> &nbsp;|&nbsp; <a href="/cs/get_involved">Get Involved</a> &nbsp;|&nbsp; <a href="/cs/donate">Donate</a> &nbsp;|&nbsp; <a href="/cs/contact_us">Contact Us</a></div></td>
				  </tr>
              </table>
            </form>
           </div>
           <div class="topnav" style="margin-top:-1px">
              <ul>
                <li class="what"><a <c:if test="${currentPage.name=='What We Do' || currentPage.section.name=='What We Do' || currentPage.section.parent.name=='What We Do' || currentPage.section.parent.parent.name=='What We Do'}">class="on"</c:if>href="/cs/what_we_do" title="What We Do"><span>What We Do</span></a></li>
                <li class="microbicide"><a <c:if test="${currentPage.name=='About Microbicides' || currentPage.section.name=='About Microbicides' || currentPage.section.parent.name=='About Microbicides' || currentPage.section.parent.parent.name=='About Microbicides'}">class="on"</c:if> href="/cs/about_microbicides" title="About Microbicides"><span>About Microbicides</span></a></li>
                <li class="database"><a <c:if test="${currentPage.name=='Microbicide R&D Database' || currentPage.section.name=='Microbicide R&D Database' || currentPage.section.parent.name=='Microbicide R&D Database' || currentPage.section.parent.parent.name=='Microbicide R&D Database'}">class="on"</c:if> href="/cs/microbicide_rd_database" title="Microbicide R&amp;D Database"><span>Micobicide R&amp;D Database</span></a></li>
                <li class="publications"><a <c:if test="${currentPage.name=='Alliance Publications' || currentPage.section.name=='Alliance Publications' || currentPage.section.parent.name=='Alliance Publications' || currentPage.section.parent.parent.name=='Alliance Publications'}">class="on"</c:if> href="/cs/alliance_publications" title="Alliance Publications"><span>Alliance Publications</span></a></li>
                <li class="resources"><a <c:if test="${currentPage.name=='Resources' || currentPage.section.name=='Resources' || currentPage.section.parent.name=='Resources' || currentPage.section.parent.parent.name=='Resources'}">class="on"</c:if> href="/cs/resources" title="Resources"><span>Resources</span></a></li>
                <li class="news"><a <c:if test="${currentPage.name=='News' || currentPage.section.name=='News' || currentPage.section.parent.name=='News' || currentPage.section.parent.parent.name=='News'}">class="on"</c:if> href="/cs/news" title="News"><span>News</span></a></li>
                <li class="meetings"><a <c:if test="${currentPage.name=='Meetings & Events' || currentPage.section.name=='Meetings & Events' || currentPage.section.parent.name=='Meetings & Events' || currentPage.section.parent.parent.name=='Meetings & Events'}">class="on"</c:if> href="/cs/meetings_events" title="Meetings &amp; Events"><span>Meetings &amp; Events</span></a></li>
                <li class="alliance"><a <c:if test="${currentPage.name=='About the Alliance' || currentPage.section.name=='About the Alliance' || currentPage.section.parent.name=='About the Alliance' || currentPage.section.parent.parent.name=='About the Alliance'}">class="on"</c:if> href="/cs/about_the_alliance" title="About the Alliance"><span>About the Alliance</span></a></li>
            </ul>
           </div>
        </td>
      </tr>
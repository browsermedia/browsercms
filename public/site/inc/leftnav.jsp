<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.browsercms.com/tags-pages" prefix="page"%>
<%@ taglib uri="http://www.browsercms.com/cms/core" prefix="cms"%>
<%@ taglib tagdir="/WEB-INF/patch" prefix="patch"%>

<page:menu fromTop="1" var="top"/>
<patch:scrub_duplicates items="${top.publicChildren}"/>
<c:set var="parentId" value="${currentPage.parent.id}"/>
<c:set var="childId" value="${currentPage.section.parent.id}"/>
<c:set var="counter" value="1"/>

<c:if test="${currentPage.section!='root'}">
<ul>
	<c:forEach items="${top.publicChildren}" var="level1" varStatus="status">
		 <li<c:if test="${level1.url==currentPage.url or level1.name==currentPage.section.name}"> class="open"</c:if>>
		  <a href="<patch:url item="${level1}"/>" <c:if test="${(level1.name!=currentPage.name) and (level1.name!=currentPage.section.name)}">onmouseover="document.btmcap${counter}.src='/site/images/leftnav_btmcap_h.gif'" onmouseout="document.btmcap${counter}.src='/site/images/leftnav_btmcap.gif'"</c:if>>${level1.name}</a>
		  <div><img src="/site/images/leftnav_btmcap<c:if test="${level1.url==currentPage.url or level1.name==currentPage.section.name}">_on</c:if>.gif" alt="" name="btmcap${counter}" width="222" height="5" /></div>

			<patch:scrub_duplicates items="${level1.publicChildren}"/>
			<c:if test="${parentId==level1.id}">
			  <ul>
				<c:forEach items="${level1.publicChildren}" var="level2" varStatus="subStatus">
				 <c:if test="${level2.name!=level1.name}"><li><a href="<patch:url item="${level2}"/>" <c:if test="${level2.url==currentPage.url}">class="on"</c:if>>${level2.name}</a>
				</li></c:if>
				</c:forEach>
			  </ul>
			</c:if>
			</li>
	  <c:set var="counter" value="${counter+1}"/>
	</c:forEach>
</ul>

</c:if>
  <%@ taglib uri="http://java.sun.com/jstl/core" prefix="c"%>
  <%@ taglib uri="http://www.browsercms.com/tags-blocks" prefix="block"%>
  <%@ taglib uri="http://www.browsercms.com/tags-pages" prefix="page"%>
  <%@ taglib uri="http://www.browsercms.com/cms/core" prefix="cms"%>


<c:set var="callout1" value="0"/>
<c:set var="callout2" value="0"/>
<c:set var="callout3" value="0"/>
<block:hasBlock container="callout1_content"><c:set var="callout1" value="1"/></block:hasBlock>
<block:hasBlock container="callout2_content"><c:set var="callout2" value="1"/></block:hasBlock>
<block:hasBlock container="callout3_content"><c:set var="callout3" value="1"/></block:hasBlock>

<jsp:include page="/site/inc/header.jsp" />
      <tr>
        <td class="leftnav">
        <div class="clear"></div>
         <div class="pad">
			<jsp:include page="/site/inc/leftnav.jsp" /></div>

        </td>
        <td class="content">
          <div class="pad"><a name="content"></a>
            <h1>${currentPage.name}</h1>
			<page:container name="content"/>

            <div class="previousnext">
            	<page:menu fromCurrent="0" var="section"/>
				<c:set var="previousPage" value=""/>
				<c:set var="previousPagename" value=""/>
				<c:set var="nextPage" value=""/>
				<c:set var="nextPagename" value=""/>
				<c:set var="currentPageStatus" value=""/>
				<c:forEach items="${section.publicChildren}" var="menuItem" varStatus="status">
					<c:if test="${menuItem.name==currentPage.name}">
						<c:set var="currentPageStatus" value="${status.count}"/>
					</c:if>
				</c:forEach>
				<c:forEach items="${section.publicChildren}" var="menuItem" varStatus="status">
					<c:if test="${status.count==currentPageStatus-1}">
						<c:set var="previousPage" value="${menuItem.url}"/>
						<c:set var="previousPagename" value="${menuItem.name}"/>
					</c:if>
					<c:if test="${status.count==currentPageStatus+1}">
						<c:set var="nextPage" value="${menuItem.url}"/>
						<c:set var="nextPagename" value="${menuItem.name}"/>
					</c:if>
				</c:forEach>
				<c:if test="${!empty previousPage}"><br><br><a href="${previousPage}"><b> &laquo; ${previousPagename}</b></a></c:if>
				<c:if test="${!empty previousPage and !empty nextPage}">|</c:if>
				<c:if test="${!empty nextPage}"><a href="${nextPage}"><b>${nextPagename} &raquo;</b></a></c:if>
            </div>
          </div>
          </td>
          <td class="sidebar">
            <div class="pad">
				<c:if test="${callout1 == '1' or pagemode.editView}">
              		<div class="boxcontent">
                		<page:container name="callout1_content" />
                	</div>
		            <div><img class="noborder" src="/site/images/sidebar_btmcap.gif" alt="" width="212" height="9" /></div>
              	</c:if>
                <c:if test="${callout2 == '1' or pagemode.editView}">
              		<div class="boxcontent">
                		<page:container name="callout2_content" />
                	</div>
		            <div><img class="noborder" src="/site/images/sidebar_btmcap.gif" alt="" width="212" height="9" /></div>
              	</c:if>
              	<c:if test="${callout3 == '1' or pagemode.editView}">
              		<div class="boxcontent">
                		<page:container name="callout3_content" />
                	</div>
		            <div><img class="noborder" src="/site/images/sidebar_btmcap.gif" alt="" width="212" height="9" /></div>
              	</c:if>
			</div>
          </td>
        </tr>

        <jsp:include page="/site/inc/footer.jsp" />

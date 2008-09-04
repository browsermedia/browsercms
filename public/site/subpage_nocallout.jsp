  <%@ taglib uri="http://java.sun.com/jstl/core" prefix="c"%>
  <%@ taglib uri="http://www.browsercms.com/tags-blocks" prefix="block"%>
  <%@ taglib uri="http://www.browsercms.com/tags-pages" prefix="page"%>
  <%@ taglib uri="http://www.browsercms.com/cms/core" prefix="cms"%>

<jsp:include page="/site/inc/header.jsp" />
      <tr>
        <td class="leftnav">
          <div class="pad">
			<jsp:include page="/site/inc/leftnav.jsp" />
			<div class="clear"></div>
		  </div>
        </td>
        <td class="content_nocallout" colspan="2">
          <div class="pad"><a name="content"></a>
			  <div class="copy" id="copy">
			  <script language="javascript">
			  <!--
				  if(document.getElementById('copy').clientHeight > 400) {
				  document.write("<br><a href='#top'>Back to top</a>");
			  }
			  //-->
			  </script>
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
					<br /><br />
					<c:if test="${!empty previousPage}"><br><br><a href="${previousPage}"><b> &laquo; ${previousPagename}</b></a></c:if>
					<c:if test="${!empty previousPage and !empty nextPage}">|</c:if>
					<c:if test="${!empty nextPage}"><a href="${nextPage}"><b>${nextPagename} &raquo;</b></a></c:if>
				</div>
			  </div>
          </div>
          </td>
        </tr>

        <jsp:include page="/site/inc/footer.jsp" />

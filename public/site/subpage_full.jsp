  <%@ taglib uri="http://java.sun.com/jstl/core" prefix="c"%>
  <%@ taglib uri="http://www.browsercms.com/tags-blocks" prefix="block"%>
  <%@ taglib uri="http://www.browsercms.com/tags-pages" prefix="page"%>
  <%@ taglib uri="http://www.browsercms.com/cms/core" prefix="cms"%>

<jsp:include page="/site/inc/header.jsp" />
      <tr>
        <td class="content_full" colspan="3">
          <div class="pad"><a name="content"></a>
            <h1>${currentPage.name}</h1>
			<page:container name="content"/>
          </div>
          </td>
        </tr>
<jsp:include page="/site/inc/footer.jsp" />
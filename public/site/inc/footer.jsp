<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.browsercms.com/tags-blocks" prefix="block"%>
<%@ taglib uri="http://www.browsercms.com/tags-pages" prefix="page"%>
<%@ taglib uri="http://www.browsercms.com/cms/core" prefix="cms"%>
<%@ taglib uri="http://java.sun.com/jstl/fmt" prefix="fmt" %>
<jsp:useBean id="current" class="java.util.Date"/>

       <tr>
          <td colspan="3" class="footer">
          	<a href="/" title="Home">Home</a> &nbsp;|&nbsp;
            <a href="/cs/sitemap" title="Sitemap">Sitemap</a> &nbsp;|&nbsp;
            <a href="/cs/privacy_policy" title="Privacy Policy">Privacy Policy</a> &nbsp;|&nbsp;
            <a href="/cs/terms_of_use" title="Terms of Use">Terms of Use</a> &nbsp;|&nbsp;
            <a href="/cs/disclaimer" title="Disclaimer">Disclaimer</a> &nbsp;|&nbsp;
            <%--<a href="/cs/website_feedback" title="Website Feedback">Website Feedback</a> &nbsp;|&nbsp; --%>
            <a href="/cs/contact_us" title="Contact Us">Contact Us</a>
			<p>Copyright &copy; <fmt:formatDate value="${current}" pattern="yyyy" type="date"/> Alliance for Microbicide Development. All rights reserved.</p>
			<br />

			<div class="bmlogos">
				<ul>
    				<li class="bmcms"><a href="http://www.browsercms.com/index.ww" title="BrowserCMS 2.0" target="_blank"><span>Powered by BrowserCMS 2.0</span></a></li>
        			<li class="bmedia"><a href="http://www.browsermedia.com/" title="BrowserMedia*" target="_blank"><span>Created by BrowserMedia*</span></a></li>
				</ul>
			</div>
			
			</td>
        </tr>
      </table>
    </td>
    <td class="rightborder"><img src="/site/images/bg_frame_right.jpg" alt="" width="45" height="800" /></td>
  </tr>
</table>
</body>
</html>
  <%@ taglib uri="http://java.sun.com/jstl/core" prefix="c"%>
  <%@ taglib uri="http://www.browsercms.com/tags-blocks" prefix="block"%>
  <%@ taglib uri="http://www.browsercms.com/tags-pages" prefix="page"%>
  <%@ taglib uri="http://www.browsercms.com/cms/core" prefix="cms"%>

<jsp:include page="/site/inc/header.jsp" />
       <tr>
		 <td colspan="3">
		   <table cellspacing="0" style="margin:14px;padding:0;">
			<tr>
				 <td colspan="2"><page:container name="mainpromo"/></td>
			</tr>
			<tr>
			  <td colspan="2"><img src="/site/images/home_hr.gif" width="897" height="15" alt="---" /></td>
			</tr>
			<tr style="background:#fff">
			  <td width="421">
				<table cellspacing="0" style="margin:20px 20px 10px;padding:0;width:381px">
				  <tr>
					<td colspan="2" class="welcome">
			          <page:container name="welcome_message"/>
			        </td>
				  </tr>
				  <tr>
					<td><a href="/cs/what_we_do"><img src="/site/images/tab_what_we_do.gif" alt="What We Do" width="141" height="28" border="0" onmouseover="this.src='/site/images/tab_what_we_do_h.gif'" onmouseout="this.src='/site/images/tab_what_we_do.gif'" /></a></td>
					<td><a href="/cs/about_microbicides"><img src="/site/images/tab_about_microbicides.gif" alt="About Microbicides" width="210" height="28" border="0" onmouseover="this.src='/site/images/tab_about_microbicides_h.gif'" onmouseout="this.src='/site/images/tab_about_microbicides.gif'" /></a></td>
				  </tr>
				</table>
			  </td>
			  <td>
				<div style="margin:12px 0 0 26px;padding:0;width:449px">
				<div style="background:url(/site/images/home_map_topcap.gif) no-repeat;color:#616161;">
				  <div class="trackingfield">
			        <page:container name="tracking_the_field"/>
				  </div>
				  <img src="/site/images/home_map_btmcap.gif" alt="" width="449" height="13" /></div>
				</div>
			  </td>
			</tr>
			<tr>
			  <td colspan="2"><img src="/site/images/home_hr.gif" alt="" width="897" height="15" /></td>
			</tr>
			<tr>
			  <td>
				<div style="margin:12px 0 0 12px;">
				  <div class="homepromoboxtop">
					<div style="float:left;width:100px">
				      <page:container name="homeboximage1"/>
			        </div>
					<div style="margin-left:102px;width:274px">
				      <page:container name="homebox1"/>
					</div>
				  </div>
				  <div style="clear:left;height:20px"><img src="/site/images/home_promo_box_btm.gif" alt="" width="408" height="10" /></div>
				    <div style="clear:left"></div>
					<div class="homepromoboxtop">
					  <div style="float:left;width:100px">
				        <page:container name="homeboximage2"/></div>
					  <div style="margin-left:102px;width:274px">
				        <page:container name="homebox2"/>
				      </div>
				    </div>
					<div style="clear:left;height:20px"><img src="/site/images/home_promo_box_btm.gif" alt="" width="408" height="10" /></div>
				  <div style="clear:left"></div>
				  <div class="homepromoboxtop">
				    <div style="float:left;width:100px">
				      <page:container name="homeboximage3"/>
				    </div>
					<div style="margin-left:102px;width:274px">
				      <page:container name="homebox3"/>
				    </div>
				    </div>
						<div style="clear:left;height:20px"><img src="/site/images/home_promo_box_btm.gif" alt="" width="408" height="10" /></div>
					</div>
			  </td>

			  <td>
				<div class="homeresourcepromos">
					<div><img src="/site/images/tab_resources.gif" alt="Resources" width="405" height="29" /></div>
					<div class="homepubs"><page:container name="homepublication1"/></div>

			   		 <div style="padding-top:22px"><img src="/site/images/tab_publications.gif" alt="Alliance Publications" width="405" height="29" /></div>

					  <div class="homepubs"><page:container name="homepublication2"/></div>

					 <div class="homepubs"><page:container name="homepublication3"/></div>

			     </div>
			  </td>
		   </tr>
		</table>
	  </td>
    </tr>

<jsp:include page="/site/inc/footer.jsp" />
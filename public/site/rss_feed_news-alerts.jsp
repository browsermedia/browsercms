<%@ page contentType="application/xml" %>
<%@ page import="com.browsercms.RssItem"%>
<%@ page import="com.browsercms.SpringUtils"%>
<%@ page import="com.browsercms.blocks.domain.Status"%>
<%@ page import="com.browsercms.portlets.pressreleases.PressRelease"%>
<%@ page import="com.browsermedia.DateFactory"%>
<%@ page import="net.sf.hibernate.HibernateException"%>
<%@ page import="net.sf.hibernate.Query"%>
<%@ page import="net.sf.hibernate.Session"%>
<%@ page import="net.sf.hibernate.SessionFactory"%>
<%@ page import="org.springframework.orm.hibernate.HibernateCallback"%>
<%@ page import="org.springframework.orm.hibernate.HibernateTemplate"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.SortedSet" %>
<%@ page import="java.util.TreeSet" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c"  %>
<%@ taglib uri="http://java.sun.com/jstl/fmt" prefix="fmt"  %>
<%
    final SessionFactory sf = (SessionFactory) SpringUtils.getBean("sessionFactory", pageContext);
    final HibernateTemplate template = new HibernateTemplate(sf);
    final String NEWS_DETAILS_URL_TEMPLATE = "/cs/news_alert_detail?pressrelease.id=:blockId";
    List releases = template.executeFind(new HibernateCallback() {
           public Object doInHibernate(Session session) throws HibernateException {
               String q =
                       " from PressRelease release" +
                       " where (release.status = :published  or release.status = :hidden)" +
                       " and release.releaseDate < :tomorrow";
               q = q + " order by release.releaseDate desc";

               Query query = session.createQuery(q);
               query.setParameter("published", Status.PUBLISHED.getKey());
               query.setParameter("hidden", Status.HIDDEN.getKey());
               query.setParameter("tomorrow", DateFactory.tomorrow());

               query.setMaxResults(10);
               return query.list();
           }

       });

    SortedSet list = new TreeSet();
    for ( int i = 0; i < releases.size(); i++ ) {
        PressRelease block = (PressRelease) releases.get( i );
        RssItem rssItem = new RssItem(block, NEWS_DETAILS_URL_TEMPLATE );
        list.add(rssItem);
    }

    Date pubDate = null;
    try {
        pubDate = ( (PressRelease)list.first() ).getReleaseDate();
    } catch ( Exception e ) {
        pubDate = new Date();
    }

    pageContext.setAttribute("items", list);
    pageContext.setAttribute("pubDate", pubDate);

%>
<rss version="2.0">
	<channel>
        <title>Microbicide.org News Alerts</title>
        <link>http://<%=pageContext.getRequest().getServerName()%>/cs/news_alerts</link>
        <description>The latest News-Alerts from the Alliance for Microbicide Development.</description>
        <pubDate><fmt:formatDate value="${pubDate}" pattern="EE, dd MMM yyyy kk:mm:ss z"/></pubDate>
        <generator>QorvisCMS</generator>
        <language>en</language>
        <category>Press Release</category>
        <copyright>Copyright - <fmt:formatDate value="${pubDate}" pattern="yyyy"/>Alliance for Microbicide Development. All rights reserved.</copyright>
<c:forEach items="${items}" var="item">
        <item>
            <title><c:out value="${item.name}"/></title>
            <link>http://<%=pageContext.getRequest().getServerName()%><c:out value="${item.url}"/></link>
            <pubDate><fmt:formatDate value="${item.publishDate}" pattern="EE, dd MMM yyyy kk:mm:ss z"/></pubDate>
            <c:forEach items="${item.categories}" var="category">
            <category><c:out value="${category}"/></category></c:forEach>
            <guid isPermaLink="false">http://<%=pageContext.getRequest().getServerName()%><c:out value="${item.url}"/></guid>
        </item>
</c:forEach>
    </channel>
</rss>

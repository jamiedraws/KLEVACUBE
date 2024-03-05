<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<ClientSiteViewData>" %>
<%@ Import Namespace="KLEVACUBE.Utils" %>

<link rel="preconnect" href="https://use.typekit.net/" crossorigin>
<link rel="dns-prefetch" href="https://use.typekit.net/">
<link rel="stylesheet" href="https://use.typekit.net/ejz5qsd.css">

<%
    ResourceWriter resourceWriter = new ResourceWriter();

    Response.Write(resourceWriter.WriteStylePreload("css/Site1/style.css"));
    Response.Write(resourceWriter.WriteLink("css/Site1/style.css"));
    Response.Write(resourceWriter.WriteScript("js/Site1/app.es5.js"));
%>
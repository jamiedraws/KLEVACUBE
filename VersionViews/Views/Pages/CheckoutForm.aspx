<%@ Page Language="C#" MasterPageFile="~/VersionViews/Views/Layouts/CheckoutFormLayout.master" Inherits="System.Web.Mvc.ViewPage<OrderPageViewData>" %>

<%@ Import Namespace="Dtm.Framework.ClientSites" %>
<%@ Import Namespace="KLEVACUBE.Utils" %>



<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <%
        Response.Redirect("https://klevarange.com.au/products/cube-cutter-vegetable-chopper-slicer-dicer-buy-1-get-1-free");
        return;
    %>
       <% 
        ResourceWriter resourceWriter = new ResourceWriter();
        Response.Write(resourceWriter.WriteScript("js/Site1/form.es5.js"));
        
        %>


</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

 
</asp:Content>



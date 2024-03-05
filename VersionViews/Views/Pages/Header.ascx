<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<ClientSiteViewData>" %>
<%@ Import Namespace="Dtm.Framework.ClientSites" %>
<%@ Import Namespace="KLEVACUBE.Navigation" %>
<%@ Import Namespace="KLEVACUBE.UIComponents" %>

<%
	// any landing page
	bool isStartPage = DtmContext.Page.IsStartPageType;

	// just the home page
	bool isIndex = DtmContext.PageCode == "Index";

	// header config
	///////////////////////////
	bool hasFingerPrint = true;
	bool hasOrderBtn = false;
	bool hasNav = true;
	///////////////////////////
	// end config

	// represents the product name 
	string productName = SettingsManager.ContextSettings["Label.ProductName"];

	// instance of the sitemap
	NavigationList sitemap = (ViewData["Sitemap"] as Sitemap ?? new Sitemap()).SitemapList;

	// home page definition
	NavigationItem homeLink = sitemap.GetItemById("home");

	// bypass repetitive content and navigate directly to the main content
	string skipLink = "#main";

	if (DtmContext.Page.PageType.Equals("upsell", StringComparison.InvariantCultureIgnoreCase))
	{
		skipLink = "#upsellTxt";
	} else if (!isStartPage)
	{
		skipLink = "#content_top";
	}

	// if the current page is a landing page, set the destination to the home page; otherwise, set the destination to the main landmark region
	string logoLink = isStartPage ? homeLink.Page : skipLink;

	// define the HTML template for the logo
	string logoTemplate = @"<a href=""{0}"" aria-label=""{1}"" class=""header__logo"">
		<picture>
			<img src=""/images/Site1/logo.svg"" alt=""{1}"" width=""334"" height=""70"">
		</picture>
	</a>";

	// merge the HTML template with the appropriate link and the product name
	string logo = string.Format(logoTemplate, logoLink, productName);

	// define the HTML template for the headline
	string headlineTemplate = @"<{0} id=""header-title"" class=""header__title"">
			<span>Precision Chopping, Slicing, Dicing and More:</span>
			<span>The <b>Ultimate Kitchen Solution</b> for <b>Effortless Meal Prep!</b></span>
		</{0}>";

	// merge the HTML template with the appropriate tag
	string headline = string.Format(headlineTemplate, isIndex ? "h1" : "div");

	// define default header class list
	string headerClassList = "view header section";
	if (hasNav)
    {
		headerClassList = string.Format("{0} header--has-nav", headerClassList);
    }

	OrderButton orderButton = (ViewData["OrderButton"] as OrderButton ?? new OrderButton());
%>

<header aria-labelledby="header-title" class="<%= headerClassList %>">
	<span class="skip-link">
		<a href="<%= skipLink %>" class="skip-link__button" id="skip-link">
			<span>Skip To Main Content?</span>
		</a>
	</span>

	<% if (isIndex && hasFingerPrint) { %>
	<nav class="fp-nav" aria-label="Quick shortcut to order online or watch the product video">
		<a href="/CheckoutForm.dtm" class="fp-nav__a fp-nav__a--order" <%= orderButton.ApplyAttributes() %>>
			<span>Order <br />Now</span>
		</a>
		<a href="#video" class="fp-nav__a">
			<span>Watch The Show</span>
		</a>
	</nav>
	<% } %>

	<div class="view__in header__in section__in">
		<div class="header__group">
			<%= logo %>
			<%= headline %>
			<% if (hasOrderBtn) { %>
			<div class="header__action">
				<%= orderButton.CreateHTML(orderButton.Text, "button button--circular") %>
			</div>
			<% } %>
		</div>
	</div>
</header>

<div id="nav-tracker"></div>

<%
if (hasNav) {
	string navLogo = logo.Replace("header__logo", "nav__logo");
	string navHeadline = string.Format(headlineTemplate, "div").Replace("header__title", "nav__title");	

	// define default nav class list
	string navClassList = "view nav section @print-only-hide";

	// assign "is-end-page" state to center-align the logo horizontally across the header bar
	if (!isStartPage)
    {
		navClassList = string.Format("{0} nav--is-end-page", navClassList);
    }
%>
<nav id="nav" aria-label="Website pages links" class="<%= navClassList %>">
	<div class="view__in section__contain nav__in nav__group">
		<%
			Response.Write(navLogo);
			Response.Write(navHeadline.Replace("header-title", "nav-desktop-title"));
		%>
		<% if (isStartPage) { %>
		<button type="button" class="nav__label" aria-label="Toggle Menu">
			<span></span>
		</button>
		<div class="nav__underlay nav__underlay--for-drawer" role="presentation"></div>
		<div class="nav__pane">
			<div class="nav__group">
				<div class="nav__list nav__tier-first">
					<%
						Response.Write(navLogo);
						Response.Write(navHeadline);



						List<NavigationItem> navLinks = sitemap.GetItemsByIdRange(new List<string> { 
							"how-it-works",
							"reviews",
							"faq",
							"manual",
							DtmContext.PageCode == "CheckoutForm" ? "mbg-index" : "mbg",
							"order-now"
						});

						foreach (NavigationItem navLink in navLinks)
						{
							string attributes = navLink.Id.Equals("order-now") ? orderButton.ApplyAttributes() : string.Empty;
							string link = sitemap.BuildHTMLElement(navLink, "nav", "nav__link", attributes);

							Response.Write(link);
						}
					%>
				</div>
			</div>
		</div>
		<% } %>
	</div>
</nav>
<% } %>
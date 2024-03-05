<%@ Page Language="C#" MasterPageFile="~/VersionViews/Views/Layouts/InternalLayout.master" Inherits="System.Web.Mvc.ViewPage<OrderPageViewData>" %>
<%@ Import Namespace="Dtm.Framework.ClientSites" %>
<%@ Import Namespace="KLEVACUBE.Models" %>
<%@ Import Namespace="KLEVACUBE.UIComponents" %>
<%@ Import Namespace="KLEVACUBE.Text" %>
<%@ Import Namespace="KLEVACUBE.Navigation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
	<link rel="preload" href="/images/Site1/bogo.webp" as="image" type="image/webp">
	<link rel="preload" href="/images/Site1/main-offer-slides/main-offer-above-fold.webp" as="image" type="image/webp">

    <%
        var mainSeoDomain = DtmContext.CampaignDomains
            .Where(cd => cd.IsSEO).FirstOrDefault()
            ?? DtmContext.CampaignDomains
            .Where(cd => cd.IsIndexable).FirstOrDefault()
            ?? DtmContext.Domain;

        string canonicalUrl = DtmContext.PageCode.Equals("Index")
            ? mainSeoDomain.Url
            : mainSeoDomain.FullDomainCustomPathContext(DtmContext.Page.PageAlias) + DtmContext.ApplicationExtension;

        canonicalUrl = canonicalUrl.Replace("http://", "https://");
	%>

	 <script type="application/ld+json">
	{
		"@context": "https://schema.org",
		"@type": "WebSite",
		"name": "Kleva Range",
		"url": "<%= canonicalUrl %>"
	}
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

<%
	string productName = SettingsManager.ContextSettings["Label.ProductName"];

	OrderButton orderButton = ViewData["OrderButton"] as OrderButton ?? new OrderButton();

	NavigationList sitemap = (ViewData["Sitemap"] as Sitemap ?? new Sitemap()).SitemapList;
%>

<main aria-labelledby="main-title" class="view main-offer main-offer--above-fold section" data-eflex-scale-vimeo-custom>
	<div id="main" class="view__anchor"></div>
	<div class="view__in section__in">
		<div class="main-offer__group">
			<div class="main-offer__offer">
				<div class="main-offer__bogo-price-order">
					<div class="main-offer__bogo">
						<picture>
							<source srcset="/images/Site1/bogo.webp" type="image/webp">
							<img src="/images/Site1/bogo.png" fetchpriority="high" alt="Buy One Get One FREE!!" width="367" height="186" loading="lazy">
						</picture>
					</div>
		
					<div class="main-offer__price-order-payment">
						<div class="main-offer__sale-price-strikethrough">
							<div class="main-offer__sale">50% OFF</div>
							<div class="main-offer__price-strikethrough">
								<div class="sr">
									<div class="sr__text">Was $159.90</div>
										<div class="offer offer--strikethrough" aria-hidden="true" role="presentation">
										<span class="offer__standfirst">Was</span>
										<span class="offer__currency">$</span>
										<span class="offer__amt">159</span>
										<span class="offer__follow">
											<span class="offer__cent">90</span>
										</span>
									</div>
								</div>
							</div>
						</div>
						<div class="main-offer__price">
							<div class="sr">
								<div class="sr__text">Now Only $79.95</div>
									<div class="offer" aria-hidden="true" role="presentation">
									<span class="offer__standfirst">Now Only</span>
									<span class="offer__currency">$</span>
									<span class="offer__amt">79</span>
									<span class="offer__follow">
										<span class="offer__cent">95</span>
										<span class="offer__disclaimer">+ P&H</span>
									</span>
								</div>
							</div>
						</div>
						<div class="main-offer__button">
							<%= orderButton.CreateHTML() %>
						</div>
						<div class="main-offer__payment">
							<%= Html.Partial("GetPaymentIcons") %>
						</div>
					</div>
				</div>

				<div class="main-offer__carousel contain contain--main-offer-carousel">
					<div class="contain__placeholder">
						<div class="slide slide--carousel slide--main-offer" data-carousel-config='{ "delay" : 7000 }'>
							<div class="slide__into" tabindex="0" id="main-offer-carousel">
								<div class="slide__item">
									<picture>
										<source srcset="/images/Site1/main-offer-slides/main-offer-above-fold.webp" type="image/webp">
										<img src="/images/Site1/main-offer-slides/main-offer-above-fold.png" fetchpriority="high" alt="60-Day Money Back Guarantee. Australian Owned Certified. Eat Healthier With A Faster Prep Time. Google Trusted Store. Free downloadable e-book with every purchase, available during checkout. 10 piece set. slice, dice, chop, shred, julienne, strip, grind, grate, zest, wedge" width="670" height="540">
									</picture>
								</div>
								<div class="slide__item">
									<picture>
										<source srcset="/images/Site1/main-offer-slides/slide-2.webp" type="image/webp">
										<img src="/images/Site1/main-offer-slides/slide-2.png" alt="More Leverage, Easier Cut! 82 Degrees" width="653" height="522" loading="lazy">
									</picture>
								</div>
								<div class="slide__item">
									<picture>
										<source srcset="/images/Site1/main-offer-slides/slide-3.webp" type="image/webp">
										<img src="/images/Site1/main-offer-slides/slide-3.png" alt="Slice & Dice 10x Faster!" width="653" height="522" loading="lazy">
									</picture>
								</div>
								<div class="slide__item">
									<picture>
										<source srcset="/images/Site1/main-offer-slides/slide-4.webp" type="image/webp">
										<img src="/images/Site1/main-offer-slides/slide-4.png" alt="6 Blade Attachments Prep Anything Fast!" width="653" height="522" loading="lazy">
									</picture>
								</div>
								<div class="slide__item">
									<picture>
										<source srcset="/images/Site1/main-offer-slides/slide-5.webp" type="image/webp">
										<img src="/images/Site1/main-offer-slides/slide-5.png" alt="Dishwasher Safe. Easy Clean Tool" width="653" height="522" loading="lazy">
									</picture>
								</div>
							</div>
							<div class="slide__nav">
								<button aria-label="Previous" class="slide__prev" type="button">
									<svg class="icon">
										<use href="#icon-chevron"></use>
									</svg>
								</button>
								<button aria-label="Next" class="slide__next" type="button">
									<svg class="icon">
										<use href="#icon-chevron"></use>
									</svg>
								</button>
							</div>
						</div>
					</div>
				</div>
			</div>

			<div class="main-offer__video-features view">
				<div id="video" class="view__anchor"></div>
				<div class="main-offer__video contain contain--video">
					<iframe src="https://player.vimeo.com/video/859059164" frameborder="0" width="500" height="281" title="Offer Commercial | <%= productName %>" loading="lazy"></iframe>
				</div>
				<div class="features-benefits">
					<h2 id="features-benefits-title" class="features-benefits__title">Features &amp; Benefits</h2>
					<ul class="features-benefits__list">
						<li><b>Multi-Function Capability:</b> One tool handles chopping, slicing, and dicing, reducing the need for multiple kitchen gadgets.</li>
						<li><b>Precision Cutting Blades:</b> Achieve consistent cuts every time, enhancing the presentation and cooking uniformity of dishes.</li>
						<li><b>Ergonomic Design:</b> Provides a comfortable grip and ensures safety, reducing the risk of cuts and injuries.</li>
						<li><b>Compact Size:</b> Easy to store and doesn't consume much counter or drawer space.</li>
						<li><b>Easy-to-Clean Components:</b> Dishwasher safe for hassle-free cleaning.</li>
						<li><b>Durable Construction:</b> Offers longevity and reliability, ensuring value for money.</li>
						<li><b>Quick Operation:</b> Saves time during food prep, allowing for more efficient meal creation.</li>
					</ul>
				</div>
			</div>

			<div class="main-offer__icons">
				<picture class="main-offer__icon">
					<source srcset="/images/Site1/one-push-operation.webp" type="image/webp">
					<img src="/images/Site1/one-push-operation.png" alt="One Push Operation"width="160" height="160"  loading="lazy">
				</picture>
				<picture class="main-offer__icon">
					<source srcset="/images/Site1/interchangeable-slicers.webp" type="image/webp">
					<img src="/images/Site1/interchangeable-slicers.png" alt="Interchangeable Slicers"width="160" height="160" loading="lazy">
				</picture>
				<picture class="main-offer__icon">
					<source srcset="/images/Site1/handy-food-catch-tray.webp" type="image/webp">
					<img src="/images/Site1/handy-food-catch-tray.png" alt="Handy Food Catch Tray"width="160" height="160" loading="lazy">
				</picture>
				<picture class="main-offer__icon">
					<source srcset="/images/Site1/bpa-free.webp" type="image/webp">
					<img src="/images/Site1/bpa-free.png" alt="BPA Free"width="160" height="160" loading="lazy">
				</picture>
				<picture class="main-offer__icon">
					<source srcset="/images/Site1/cleaning-tool-inside.webp" type="image/webp">
					<img src="/images/Site1/cleaning-tool-inside.png" alt="Cleaning Tool Inside"width="160" height="160" loading="lazy">
				</picture>
				<picture class="main-offer__icon">
					<source srcset="/images/Site1/dishwasher-safe.webp" type="image/webp">
					<img src="/images/Site1/dishwasher-safe.png" alt="Dishwasher Safe" width="160" height="160" loading="lazy">
				</picture>
			</div>
		</div>
	</div>
</main>

<section aria-labelledby="competition-title" class="view competition section">
	<div id="how-it-works" class="view__anchor"></div>
	<div id="competition" class="view__anchor"></div>
	<div class="view__in competition__in section__in">
		<h2 id="competition-title" class="competition__title">Cuts <b>The Competition</b> To Shreds!</h2>
		<div class="competition__grid">
			<figure class="competition__figure">
				<div class="competition__picture contain contain--video" data-src-iframe="https://player.vimeo.com/video/859052962?background=1&autopause=0" data-attr='{ "title" : "Effortless Meal Prep Animation", "frameborder" : "0", "width" : "380", "height" : "213" }'>
					<picture>
						<source srcset="/images/Site1/video-loops/859052962.webp" type="image/webp">
						<img src="/images/Site1/video-loops/859052962.jpg" alt="" width="380" height="213" loading="lazy">
					</picture>
				</div>
				<figcaption class="competition__figcaption">
					<h3 class="competition__name">Effortless Meal Prep</h3>
					<p>Transform tedious chopping and slicing into a breeze.</p>
				</figcaption>
			</figure>
			<figure class="competition__figure">
				<div class="competition__picture contain contain--video" data-src-iframe="https://player.vimeo.com/video/859054130?background=1&autopause=0" data-attr='{ "title" : "Versatile Blades Animation", "frameborder" : "0", "width" : "380", "height" : "213" }'>
					<picture>
						<source srcset="/images/Site1/video-loops/859054130.webp" type="image/webp">
						<img src="/images/Site1/video-loops/859054130.jpg" alt="" width="380" height="213" loading="lazy">
					</picture>
				</div>
				<figcaption class="competition__figcaption">
					<h3 class="competition__name">Versatile Blades</h3>
					<p>Stainless steel precision for slicing, dicing, and chopping.</p>
				</figcaption>
			</figure>
			<figure class="competition__figure">
				<div class="competition__picture contain contain--video" data-src-iframe="https://player.vimeo.com/video/859058119?background=1&autopause=0" data-attr='{ "title" : "Uniform Results Animation", "frameborder" : "0", "width" : "380", "height" : "213" }'>
					<picture>
						<source srcset="/images/Site1/video-loops/859058119.webp" type="image/webp">
						<img src="/images/Site1/video-loops/859058119.jpg" alt="" width="380" height="213" loading="lazy">
					</picture>
				</div>
				<figcaption class="competition__figcaption">
					<h3 class="competition__name">Uniform Results</h3>
					<p>Cube Cutter ensures even cooking with precise cuts.</p>
				</figcaption>
			</figure>
		</div>
	</div>
</section>

<section aria-labelledby="unlock-product-title" class="view unlock-product section">
	<div id="unlock-product" class="view__anchor"></div>
	<div class="view__in unlock-product__in section__in">
		<div class="unlock-product__grid">
			<div class="unlock-product__text">
				<h2 id="unlock-product-title" class="unlock-product__title">Unlock <b>Lightning-Fast Meal Prep</b> with <%= productName %></h2>
				<p>Tired of spending hours on meal prep with uneven results? Transform your kitchen experience with the <%= productName %>. Renowned by chefs and featured on TV, this innovative tool promises not only speed but also precision in every slice, dice, and chop.</p>

				<h3 class="unlock-product__heading">Why Choose the <%= productName %>?</h3>
				<p><b>Efficiency on Demand:</b> Slash your preparation time and easily navigate through fruits and vegetables, all thanks to the cutter's diverse blade attachments.</p>

				<p><b>Cutting Excellence:</b> Achieve perfectly uniform pieces every time, ensuring your meals cook evenly and look professionally done.</p>

				<p><b>Safety First:</b> Designed with precision and safety at its core, you can confidently chop without the fear of accidental nicks or cuts.</p>

				<p><b>Post-Prep Convenience:</b> Cleanup is a breeze with its effortlessly detachable parts, letting you transition from prepping to enjoying your meal in no time. Plus, its compact design ensures a clutter-free kitchen.</p>

				<p>Say no to mundane, time-consuming prep and elevate your cooking game with the unparalleled precision and speed of the <%= productName %>.</p>
			</div>
			<div class="unlock-product__picture-order-button">
				<picture>
					<source srcset="/images/Site1/product-usage-grid.webp" type="image/webp">
					<img src="/images/Site1/product-usage-grid.png" alt="Keep your fingers safe. One push perfect veggies! Slice & Dice 10x Faster! Fast Prep for every meal!" width="489" height="490" loading="lazy">
				</picture>
				<div class="unlock-product__button">
					<%= orderButton.CreateHTML("Click Here To Order Now") %>
				</div>
			</div>
		</div>
	</div>
</section>

<section aria-labelledby="blade-attachments-title" class="view blade-attachments section">
	<div id="blade-attachments" class="view__anchor"></div>
	<div class="view__in blade-attachments__in section__in">
		<header class="blade-attachments__header">
			<h2 id="blade-attachments-title" class="blade-attachments__title">Create a Culinary Masterpiece with <b>6 Different Blade Attachments</b></h2>
			<p>With 6 different blade attachments, you can cut all types of fruits and vegetables into the perfect shape and size needed for any dish.</p>
			<p>The 2 cube cutter attachments allow you to dice your food in an instant with 2 different sizes. For other desired texture or consistency you can also choose the thin or julienne slicer, and  the coarse and fine grater, providing endless possibilities to your culinary creations.</p>
		</header>

		<div class="blade-attachments__grid">
			<figure class="blade-attachments__figure">
				<picture>
					<source srcset="/images/Site1/thick-cube-cutter.webp" type="image/webp">
					<img src="/images/Site1/thick-cube-cutter.jpg" alt="Thick Cube Cutter" width="317" height="224" loading="lazy">
				</picture>
				<figcaption class="blade-attachments__figcaption">
					<h3 class="blade-attachments__name">Thick Cube Cutter</h3>
					<p class="blade-attachments__desc"><b>Perfect for:</b> Cubed carrot, zucchini and tomato</p>
				</figcaption>
			</figure>
			<figure class="blade-attachments__figure">
				<picture>
					<source srcset="/images/Site1/thin-cube-cutter.webp" type="image/webp">
					<img src="/images/Site1/thin-cube-cutter.jpg" alt="Thin Cube Cutter" width="314" height="219" loading="lazy">
				</picture>
				<figcaption class="blade-attachments__figcaption">
					<h3 class="blade-attachments__name">Thin Cube Cutter</h3>
					<p class="blade-attachments__desc"><b>Perfect for:</b> Diced apple, capsicum and onion</p>
				</figcaption>
			</figure>
			<figure class="blade-attachments__figure">
				<picture>
					<source srcset="/images/Site1/thick-slicer.webp" type="image/webp">
					<img src="/images/Site1/thick-slicer.jpg" alt="Thick Slicer" width="317" height="216" loading="lazy">
				</picture>
				<figcaption class="blade-attachments__figcaption">
					<h3 class="blade-attachments__name">Thick Slicer</h3>
					<p class="blade-attachments__desc"><b>Perfect for:</b> Sliced potato, fruit and vegetables</p>
				</figcaption>
			</figure>
			<figure class="blade-attachments__figure">
				<picture>
					<source srcset="/images/Site1/julienne-slicer.webp" type="image/webp">
					<img src="/images/Site1/julienne-slicer.jpg" alt="Julienne Slicer" width="317" height="221" loading="lazy">
				</picture>
				<figcaption class="blade-attachments__figcaption">
					<h3 class="blade-attachments__name">Julienne Slicer</h3>
					<p class="blade-attachments__desc"><b>Perfect for:</b> Julienne carrots, zucchini and parsnip</p>
				</figcaption>
			</figure>
			<figure class="blade-attachments__figure">
				<picture>
					<source srcset="/images/Site1/coarse-grater.webp" type="image/webp">
					<img src="/images/Site1/coarse-grater.jpg" alt="Coarse Grater" width="317" height="224" loading="lazy">
				</picture>
				<figcaption class="blade-attachments__figcaption">
					<h3 class="blade-attachments__name">Coarse Grater</h3>
					<p class="blade-attachments__desc"><b>Perfect for:</b> Grated cheese, cabbage and bok choy</p>
				</figcaption>
			</figure>
			<figure class="blade-attachments__figure">
				<picture>
					<source srcset="/images/Site1/fine-grater.webp" type="image/webp">
					<img src="/images/Site1/fine-grater.jpg" alt="Fine Grater" width="317" height="218" loading="lazy">
				</picture>
				<figcaption class="blade-attachments__figcaption">
					<h3 class="blade-attachments__name">Fine Grater</h3>
					<p class="blade-attachments__desc"><b>Perfect for:</b> Grater garlic, chocolate and ginger</p>
				</figcaption>
			</figure>
		</div>
	</div>
</section>

<section aria-labelledby="reviews-title" class="view reviews reviews--display-top-reviews section">
	<div id="reviews" class="view__anchor"></div>
	<div class="view__in section__in">
		<header class="reviews__header">
			<h2 id="reviews-title" class="reviews__title">Don't Just Take Our Word For It!</h2>
			<p><b>Hey there, kitchen warriors!</b> Don't just take our word for it &mdash; hear it straight from folks who've experienced the magic of the <%= productName %>! These are real testimonials from real people who've turned their kitchen chores into a breeze. Dive right in and see why folks everywhere are saying the <%= productName %> is the game-changer they've been waiting for!</p>
		</header>

		<div class="reviews__reviews">
		<% 
			List<Review> reviews = new List<Review>
            {
				new Review
                {
					Name = "Love This",
					Blockquote = "Absolutely love this. Such a great addition to my kitchen, I gave one to my daughter and she loves it too!"
                },
				new Review
                {
					Name = "Does As Advertised",
					Blockquote = "This is everything that its advertised to be. It's a god send in the kitchen and makes preparing meals so much quicker"
                },
				new Review
                {
					Name = "Makes Cooking So Much Faster!",
					Blockquote = "This product makes cooking so much easier for me since I have arthritis in both hands. Easy to clean, so efficient and looks great."
                }
            };
 
			reviews.ForEach(review =>
            {
				%>
				<figure class="review-card">
					<picture class="review-card__rating">
						<img src="/images/Site1/stars.svg" alt="5 Stars" width="104" height="19" loading="lazy">
					</picture>
					<figcaption><%= review.Name %></figcaption>
					<blockquote><%= review.Blockquote %></blockquote>
				</figure>
				<%
            });
		%>
		</div>

		<%
			NavigationItem reviewsLink = sitemap.GetItemById("reviews-direct");
			
			if (sitemap.HasItem(reviewsLink))
            {
				%>
				<div class="reviews__footer">
					<a href="<%= reviewsLink.Page %>" class="button">
						<span>See All Reviews</span>
					</a>
				</div>
				<%
            }
		%>
	</div>
</section>

</asp:Content>
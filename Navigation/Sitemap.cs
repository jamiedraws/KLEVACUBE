namespace KLEVACUBE.Navigation
{
    public class Sitemap
    {
        /// <summary>
        /// Represents a complete, collection of destinations for a single website 
        /// </summary>
        public NavigationList SitemapList;
        /// <summary>
        /// A dictionary of all destinations and landmarks for a single website
        /// </summary>
        public Sitemap()
        {
            SitemapList = new NavigationList();

            // Home
            SitemapList.AddItem(new NavigationItem
            {
                Id = "home",
                Name = "Home",
                Page = "Index",
                Hash = "#main"
            });

            // How It Works
            SitemapList.AddItem(new NavigationItem
            {
                Id = "how-it-works",
                Name = "How It Works",
                Page = "Index",
                Hash = "#how-it-works",
                ApplyHash = true
            });

            // FAQ
            SitemapList.AddItem(new NavigationItem
            {
                Id = "faq",
                Name = "FAQ",
                Page = "FAQ",
                Hash = "#main"
            });

            // Customer Service
            SitemapList.AddItem(new NavigationItem
            {
                Id = "customer-service",
                Name = "Customer Service",
                Page = "Customer-Service",
                Hash = "#main"
            });

            // Money Back Guarantee
            SitemapList.AddItem(new NavigationItem
            {
                Id = "mbg",
                Name = "Money Back Guarantee",
                Hash = "#mbg"
            });

            // Money Back Guarantee Index
            SitemapList.AddItem(new NavigationItem
            {
                Id = "mbg-index",
                Name = "Money Back Guarantee",
                Page = "Index",
                Hash = "#mbg",
                ApplyHash = true
            });

            // Instruction Manual
            SitemapList.AddItem(new NavigationItem
            {
                Id = "manual",
                Name = "Instruction Manual",
                Page = "/pdf/Print_Cube_Slicer_IM.pdf",
                IsExternal = true
            });

            // Reviews
            SitemapList.AddItem(new NavigationItem
            {
                Id = "reviews",
                Name = "Five Star Reviews",
                Page = "Index",
                Hash = "#reviews",
                ApplyHash = true
            });

            // Reviews Direct
            SitemapList.AddItem(new NavigationItem
            {
                Id = "reviews-direct",
                Name = "Five Star Reviews",
                Page = "Reviews",
                Hash = "#main"
            });

            // Shipping Policy
            SitemapList.AddItem(new NavigationItem
            {
                Id = "shipping-policy",
                Name = "Shipping Policy",
                Page = "Shipping-Policy",
                Hash = "#main"
            });

            // Return Policy
            SitemapList.AddItem(new NavigationItem
            {
                Id = "return-policy",
                Name = "Return Policy",
                Page = "Return-Policy",
                Hash = "#main"
            });

            // Security Policy
            SitemapList.AddItem(new NavigationItem
            {
                Id = "security-policy",
                Name = "Security Policy",
                Page = "Security-Policy",
                Hash = "#main"
            });

            // Privacy Policy
            SitemapList.AddItem(new NavigationItem
            {
                Id = "privacy-policy",
                Name = "Privacy Policy",
                Page = "Privacy-Policy",
                Hash = "#main"
            });

            // Site Map
            SitemapList.AddItem(new NavigationItem
            {
                Id = "sitemap",
                Name = "Site Map",
                Page = "SiteMap",
                Hash = "#main"
            });

            // Order Now
            SitemapList.AddItem(new NavigationItem
            {
                Id = "order-now",
                Name = "Order Now",
                Page = "CheckoutForm",
                Hash = "#order"
            });
        }

    }
}
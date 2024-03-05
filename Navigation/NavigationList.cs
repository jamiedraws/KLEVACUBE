using Dtm.Framework.ClientSites.Web;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace KLEVACUBE.Navigation
{
    public class NavigationList
    {
        /// <summary>
        /// Collection of items that follow specific rules and constraints
        /// </summary>
        public List<NavigationItem> Entries;

        /// <summary>
        /// Utility that is designed to collect information about an item or list of items that represent a link or a button
        /// </summary>
        public NavigationList()
        {
            Entries = new List<NavigationItem>();
        }

        /// <summary>
        /// Takes a `NavigationItem`, applies the rules and constraints and adds to the entries list
        /// </summary>
        /// <param name="item"></param>
        public void AddItem(NavigationItem item)
        {
            Entries.Add(SetPage(item));
        }

        /// <summary>
        /// Determines if the item exists
        /// </summary>
        /// <param name="item"></param>
        /// <returns></returns>
        public bool HasItem(NavigationItem item)
        {
            return !string.IsNullOrEmpty(item.Id) && !string.IsNullOrWhiteSpace(item.Id);
        }

        /// <summary>
        /// Returns an individual item based on the id
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public NavigationItem GetItemById(string id)
        {
            var entry = Entries.Where(i => i.Id == id);

            return entry.Any() ? entry.FirstOrDefault() : new NavigationItem();
        }

        /// <summary>
        /// Returns a new filtered list of items based on the list of id's provided
        /// </summary>
        /// <param name="idRange"></param>
        /// <returns></returns>
        public List<NavigationItem> GetItemsByIdRange(List<string> idRange)
        {
            var entries = new List<NavigationItem>();

            foreach (var id in idRange)
            {
                entries.Add(GetItemById(id));
            }

            return entries.Where(entry => HasItem(entry)).ToList();
        }

        /// <summary>
        /// Determines if the item being compared is equal to the current page alias. For items that share the same page alias, the destination will result in the hash fragment.
        /// </summary>
        /// <param name="page"></param>
        /// <returns></returns>
        public bool IsOnSamePage(string page)
        {
            return string.Equals(page, DtmContext.Page.PageAlias, StringComparison.InvariantCultureIgnoreCase) || string.Equals(page, DtmContext.Page.PageCode, StringComparison.InvariantCultureIgnoreCase);
        }


        /// <summary>
        /// Sets the item to follow the appropriate rules and constraints 
        /// </summary>
        /// <param name="item"></param>
        /// <returns></returns>
        public NavigationItem SetPage(NavigationItem item)
        {
            if (item.IsExternal)
            {
                return item;
            }

            if (string.IsNullOrEmpty(item.Page) && !string.IsNullOrEmpty(item.Hash))
            {
                item.Page = item.Hash;

                return item;
            }

            item.Page = !string.IsNullOrEmpty(item.Route) 
                ? string.Format("/{0}", item.Route)
                : IsOnSamePage(item.Page)
                    ? item.Hash
                    : FormatPageByOfferVersion(item);

            return item;
        }

        /// <summary>
        /// Takes a NavigationItem and builds an HTMLAnchorElement or HTMLButtonElement with the NavigationItem constraints applied.
        /// </summary>
        /// <param name="item"></param>
        /// <param name="labelId"></param>
        /// <returns></returns>
        public string BuildHTMLElement(NavigationItem item, string labelId, string classListOverride = "", string attributeListOverride = "")
        {
            string html = string.Empty;

            if (!HasItem(item)) return html;

            // represents the name of the link
            string name = item.Name;

            // discern each link using a combination of identifiers
            string id = string.Format(@"{0}-{1}", labelId, item.Id);

            string attributeList = string.Format(@"id=""{0}-link""", id);
            string classList = string.Format(@"{0}", classListOverride);

            // add attributes to operate a modal-dialog link
            if (item.IsModalDialog)
            {
                attributeList = string.Format(@"{0} data-modal-dialog-id=""{1}"" data-modal-dialog-actor=""open"" data-modal-dialog-template-modifier=""{1}"" data-modal-dialog-title=""{2}""",
                    attributeList, item.Id, item.Name
                );
            }
            else
            {
                // define attributes for the link
                attributeList = string.Format(@"href=""{0}"" {1}", item.Page, attributeList);
            }

            // add ajax view
            if (item.ContentView.Equals(ContentView.Ajax))
            {
                attributeList = string.Format(@"{0} data-partial-view-id=""{1}-partial"" data-modal-dialog-same-origin-url", attributeList, item.Id);

                return string.Format(@"<button type=""button"" {0}>{1}</button>", attributeList, name);
            }

            if (item.ContentView.Equals(ContentView.Iframe))
            {
                attributeList = string.Format(@"{0} data-modal-dialog-iframe=""{1}""", attributeList, item.Page);
            }

            // add attributes to operate an external link
            if (item.IsExternal)
            {
                attributeList = string.Format(@"{0} target=""_blank""", attributeList);
                classList = string.Format("{0} link", classList);
                name = string.Format(@"{0} <span class=""link__advisal""><span class=""link__container"">Opens in a new window</span></span>", name);
            }

            attributeList = string.Format(@"{0} href=""{1}""", attributeList, item.Page);

            if (!string.IsNullOrWhiteSpace(classList))
            {
                attributeList = string.Format(@"{0} class=""{1}""", attributeList, classList);
            }

            if (!string.IsNullOrWhiteSpace(attributeListOverride))
            {
                attributeList = string.Format(@"{0} {1}", attributeList, attributeListOverride);
            }

            return string.Format(@"<a {0}>{1}</a>", attributeList, name);
        }

        /// <summary>
        /// Returns the page alias including the offer-version context
        /// </summary>
        /// <param name="item"></param>
        /// <returns></returns>
        private string FormatPageByOfferVersion(NavigationItem item)
        {
            return string.Format("/{0}/{1}/{2}{3}{4}",
                DtmContext.OfferCode,
                DtmContext.Version,
                item.Page,
                DtmContext.ApplicationExtension,
                item.ApplyHash ? item.Hash : string.Empty);
        }

    }
}
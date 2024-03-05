using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace KLEVACUBE.Navigation
{
    public enum ContentView
    {
        /// <summary>
        /// Deliver content through a standard webpage request
        /// </summary>
        Redirect = 0,
        /// <summary>
        /// Deliver content inside an HTMLIFrameElement
        /// </summary>
        Iframe = 1,
        /// <summary>
        /// Deliver content using asynchronous JavaScript and XML method
        /// </summary>
        Ajax = 2
    }

    public class NavigationItem
    {
        /// <summary>
        /// Represents the unique identifier
        /// </summary>
        public string Id { get; set; }
        /// <summary>
        /// Represents the human-readable name
        /// </summary>
        public string Name { get; set; }
        /// <summary>
        /// Represents the page alias or page code
        /// </summary>
        public string Page { get; set; }
        /// <summary>
        /// Represents the label that can offer more context where the name cannot
        /// </summary>
        public string Label { get; set; }
        /// <summary>
        /// Represents the URI fragment that serves as a destination marker
        /// </summary>
        public string Hash { get; set; }
        /// <summary>
        /// Represents the URL route
        /// </summary>
        public string Route { get; set; }
        /// <summary>
        /// Determines if the item intends to leave the current site
        /// </summary>
        public bool IsExternal { get; set; }
        /// <summary>
        /// Determines if the item serves as a drop-down button
        /// </summary>
        public bool IsDropDown { get; set; }
        /// <summary>
        /// Directive that applies the hash fragment regardless
        /// </summary>
        public bool ApplyHash { get; set; }
        /// <summary>
        /// Determines if the item contains a route
        /// </summary>
        public bool IsRoute { get; set; }
        /// <summary>
        /// Determines if the item serves as a modal-dialog button
        /// </summary>
        public bool IsModalDialog { get; set;}
        /// <summary>
        /// Determines how the content behind the navigation item should be displayed.
        /// </summary>
        public ContentView ContentView { get; set; }
        /// <summary>
        /// Contains information around an item that represents a link or button.
        /// </summary>
        public NavigationItem()
        {
            Id = string.Empty;
            Name = string.Empty;
            Page = string.Empty;
            Label = string.Empty;
            Hash = string.Empty;
            Route = string.Empty;
            IsExternal = false;
            IsDropDown = false;
            ApplyHash = false;
            IsRoute = false;
            IsModalDialog = false;
            ContentView = 0;
        }
    }
}
(function () {
    "use strict";

    var reduceMotion = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    if (reduceMotion) return;

    function setupPageMotion() {
        var app = document.querySelector(".app-frame");
        if (!app) return;

        var revealItems = [];
        if (document.querySelector(".reference-hero")) {
            revealItems = Array.prototype.slice.call(document.querySelectorAll(
                ".hero-copy, .hero-visual, #features .center-heading, .feature-row, .showcase-preview, " +
                "#how-it-works .center-heading, .journey-steps article, .courses-heading, .course-grid .course-card, .closing-cta"
            ));
        }

        if (revealItems.length && "IntersectionObserver" in window) {
            revealItems.forEach(function (item) { item.classList.add("motion-reveal"); });
            document.documentElement.classList.add("motion-enabled");
            var observer = new IntersectionObserver(function (entries) {
                entries.forEach(function (entry) {
                    if (!entry.isIntersecting) return;
                    entry.target.classList.add("motion-visible");
                    observer.unobserve(entry.target);
                });
            }, { threshold: 0.12, rootMargin: "0px 0px -35px 0px" });
            revealItems.forEach(function (item) { observer.observe(item); });
        } else {
            document.documentElement.classList.add("motion-enabled");
        }

        document.addEventListener("click", function (event) {
            var link = event.target.closest("a[href]");
            if (!link || event.defaultPrevented || event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
            if (link.target && link.target !== "_self" || link.hasAttribute("download")) return;

            var destination;
            try { destination = new URL(link.href, window.location.href); }
            catch (ignore) { return; }
            if (destination.origin !== window.location.origin) return;
            if (destination.pathname === window.location.pathname && destination.search === window.location.search && destination.hash) return;
            if (destination.href === window.location.href) return;

            event.preventDefault();
            document.documentElement.classList.add("page-leaving");
            window.setTimeout(function () { window.location.assign(destination.href); }, 130);
        });
    }

    window.addEventListener("pageshow", function () {
        document.documentElement.classList.remove("page-leaving");
    });

    if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", setupPageMotion);
    else setupPageMotion();
}());

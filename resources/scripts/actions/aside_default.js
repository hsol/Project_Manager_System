(function (root) {
    responsive();

    if (document.getElementById("caption")) {
        var pageHead = document.getElementById("caption").innerText != "" ? document.getElementById("caption").innerText : location.href.getValueByKey("scope");
        var asideList = document.getElementById("aside").querySelectorAll("ul li");
        var a;
        for (var i in asideList) {
            if (typeof asideList[i].innerHTML != "undefined") {
                a = asideList[i].querySelector("a");
                if (a.innerText == pageHead || a.getAttribute("scope") == pageHead) {
                    api.add.class(asideList[i], "on");
                    api.const.location = a.innerText;
                }
                else
                    api.remove.class(asideList[i], "on");
            }
        }
    }
    window.onresize = function () {
        responsive();
    };
    window.onscroll = function () {
        responsive();
    };

    function responsive() {
        if (window.innerWidth <= 800)
            api.el.aside.style.left = "-200px";
        else
            api.el.aside.style.left = null;

        if (api.el.article.querySelector("#article")) {
            var pivot = api.el.article.querySelector("#article").childNodes[1];
            if (typeof pivot === "object") {
                api.set.flexHeight(pivot);
            }
        } else {
            console.error("flex timeout. reload ui.");
            setTimeout(function () {
                var pivot = api.el.article.querySelector("#article").childNodes[1];
                if (typeof pivot === "object") {
                    api.set.flexHeight(pivot);
                }
            }, 500);
        }
    }
})(this);
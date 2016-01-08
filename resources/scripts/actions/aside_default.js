(function (root) {
    responsive();

    if (document.getElementById("caption")) {
        var pageHead = document.getElementById("caption").innerText;
        var asideList = document.getElementById("aside").querySelectorAll("ul li");
        for (var i in asideList) {
            if (typeof asideList[i].innerHTML != "undefined") {
                if (asideList[i].querySelector("a").innerText == pageHead)
                    api.add.class(asideList[i], "on");
                else
                    api.remove.class(asideList[i], "on");
            }
        }
    }
    window.onresize = function () {
        responsive();
    };

    function responsive() {
        if (window.innerWidth <= 800)
            api.el.aside.style.left = "-200px";
        else
            api.el.aside.style.left = null;

        console.log(api.el.article.querySelector("#article").childNodes);
        var pivot = api.el.article.querySelector("#article").childNodes[1];
        if (typeof pivot === "object") {
            api.set.flexHeight(pivot);
        }
    }
})(this);
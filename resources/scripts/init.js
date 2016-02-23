(function(root){
    if( typeof api === 'undefined' || void 0 === api){
        alert("api NOT LOADED");
    }else{
        window.onload = function(){
            api.parent = root;
            api.io = {};

            api.get.html("/templates/header_default.html", function(header){
                api.get.script("/resources/scripts/actions/header_default.js");
                api.get.style("/resources/styles/interfaces/header_default.css");
                api.el.header.innerHTML = header;
            });

            api.get.html("/templates/aside_default.html", function(aside){
                api.get.script("/resources/scripts/actions/aside_default.js");
                api.get.style("/resources/styles/interfaces/aside_default.css");
                api.el.aside.innerHTML = aside;
            });

            if(document.body.getAttribute("directory") && document.body.getAttribute("page"))
                api.loadPage(api.el.article, document.body.getAttribute("directory"), document.body.getAttribute("page"));

            api.get.html("/templates/footer_default.html", function(footer){
                api.get.style("/resources/styles/interfaces/footer_default.css");
                api.el.footer.innerHTML = footer;
            });
        };
    }
})(this);
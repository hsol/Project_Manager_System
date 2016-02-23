(function (root) {
    const boardList = document.getElementById("boardList");
    const URL = "/modules/board.asp";

    if (location.href.getValueByKey("scope")) {
        var param;

        boardList.querySelector("h1").innerText = convertTemplate.from(boardList.querySelector("h1").innerText, {pageHead: api.const.location});

        param = {
            role: "getBoards",
            head: location.href.getValueByKey("scope"),
            PAGE: api.const.page,
            RFP: location.href.getValueByKey("rfp") ? location.href.getValueByKey("rfp") : api.const.rfp,
            orderBy: location.href.getValueByKey("orderBy") ? location.href.getValueByKey("orderBy") : "",
            sString: "",
            sType: ""
        };
        api.ajax({
            type: "GET",
            url: URL,
            data: param,
            contentType: "application/json;",
            success: function (data) {
                var responseData = JSON.parse(data);
                var posts = boardList.querySelector(".posts");
                var innerHTML = posts.innerHTML.replace(RegExp("template", "gi"), "");

                posts.innerHTML = null;
                for (var i in responseData.list) {
                    posts.innerHTML += convertTemplate.from(innerHTML, responseData.list[i]);
                }

                api.printPaging(document.querySelector(".pagination"),api.const.page, responseData.maxCount);
            }
        });
    } else {
        alert("존재하지 않는 게시판입니다.");
        history.back();
    }
})(this);
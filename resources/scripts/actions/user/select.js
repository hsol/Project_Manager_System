(function(root) {
    const userList = document.getElementById("userList");
    const userPopup = document.getElementById('user_select');
    const URL = "/modules/user.asp";

    var param = {
        role: "getUserList",
        page: 1,
        rfp: api.const.rfp,
        sType : userPopup.querySelector(".aside .search select[name=sType]").value,
        sString : userPopup.querySelector(".aside .search input[name=sString]").value
    };
    var innerHTML = userList.innerHTML.replace(RegExp("template", "gi"), "");

    var loadUserList = function(URL, param){
        api.ajax({
            type: "GET",
            url: URL,
            data: param,
            contentType: "application/json;",
            success: function (data) {
                var responseData = JSON.parse(data);
                var temp = null;
                var user = {
                    idx: null,
                    id: null,
                    name: null,
                    part: null
                };
                responseData.state = api.convert.stringToBoolean(responseData.state == null ? "true" : responseData.state);
                if (responseData.state) {
                    api.remove.el(userList.querySelector(".template"));
                    for (var i in responseData.list) {
                        temp = document.createElement("tbody");
                        temp.innerHTML = convertTemplate.from(innerHTML, responseData.list[i]);

                        temp.childNodes[1].onclick = function (e) {
                            user.idx = e.target.parentNode.childNodes[1].innerText;
                            user.id = e.target.parentNode.childNodes[3].innerText;
                            user.name = e.target.parentNode.childNodes[5].innerText;
                            user.part = e.target.parentNode.childNodes[7].innerText;

                            var selected = document.querySelector("#user_select .aside .selected");
                            var isNotAlready = true;
                            for(var j in selected.querySelectorAll("li")){
                                var li = selected.querySelectorAll("li")[j];
                                if(li.getAttribute)
                                    if(li.getAttribute("data-id") == user.id)
                                        isNotAlready = false;
                            }
                            if(isNotAlready) {
                                var userLabel = document.createElement("li");
                                var userDel = document.createElement("span");
                                var userName = document.createElement("span");
                                userLabel.setAttribute("data-id", user.id);
                                userDel.setAttribute("class", "delete");
                                userDel.onclick = function (e) {
                                    var userLabel = e.target.parentNode;
                                    api.remove.el(userLabel);
                                };
                                userName.setAttribute("class", "name");
                                userName.innerText = user.name;
                                userLabel.appendChild(userDel);
                                userLabel.appendChild(userName);
                                selected.appendChild(userLabel);
                            }
                            else
                                alert("이미 존재하는 사람입니다.");
                        };
                        userList.appendChild(temp.childNodes[1]);
                    }

                    if( userPopup.querySelector(".moreUser")) {
                        if (responseData.maxCount <= api.const.rfp * param.page)
                            api.remove.el(userPopup.querySelector(".moreUser"));
                        else
                            userPopup.querySelector(".moreUser").setAttribute("data-page", param.page);
                    }
                }
                else {
                    alert(responseData.message);
                }
            }
        });
    };
    loadUserList(URL, param);

    api.set.event("#userSearch", "click", function(e){
        userList.innerHTML = "";

        param = {
            role : "getUserList",
            rfp : api.const.rfp,
            sType : userPopup.querySelector(".aside .search select[name=sType]").value,
            sString : userPopup.querySelector(".aside .search input[name=sString]").value
        };
        loadUserList(URL, param);
    });

    api.set.event(userPopup.querySelector(".moreUser td"), "click", function(e){
        param = {
            role : "getUserList",
            page : userPopup.querySelector(".moreUser").getAttribute("data-page"),
            rfp : api.const.rfp,
            sType : userPopup.querySelector(".aside .search select[name=sType]").value,
            sString : userPopup.querySelector(".aside .search input[name=sString]").value
        };
        param.page = parseInt(param.page) + 1;
        loadUserList(URL, param);
    });

    api.set.event(userPopup.querySelector(".submit input[type=button]"), "click", function(e){
        var selected = userPopup.querySelector(".aside .selected");
        var global_userList = document.getElementById("global_userList") ? document.getElementById("global_userList") : document.createElement("div");
        global_userList.setAttribute("id", "global_userList");
        global_userList.setAttribute("class", "hidden");

        global_userList.innerHTML = selected.innerHTML;
        document.body.appendChild(global_userList);

        userPopup.onclose();
    });
})(this);
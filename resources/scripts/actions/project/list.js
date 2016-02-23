(function (root) {
    const projectList = document.getElementById("projectList");
    const URL = "/modules/project.asp";
    var param = {};
    param.role = "getProjectTotal";
    param.startDate = "";
    param.endDate = "";
    api.ajax({
        type: "GET",
        url: URL,
        data: param,
        contentType: "application/json;",
        success: function (data) {
            var responseData = JSON.parse(data);
            responseData.state = api.convert.stringToBoolean(responseData.state == null ? "true" : responseData.state);
            if (responseData.state) {
                var summary = projectList.querySelector(".summary");
                var innerHTML = summary.innerHTML.replace(RegExp("template", "gi"), "");

                summary.innerHTML = convertTemplate.from(innerHTML, responseData);
            }
            else {
                alert(responseData.message);
            }
        }
    });

    param = {
        role : "getProjects",
        PAGE : api.const.page,
        RFP : location.href.getValueByKey("rfp") ? location.href.getValueByKey("rfp") : api.const.rfp,
        orderBy : location.href.getValueByKey("orderBy") ? location.href.getValueByKey("orderBy") : "",
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
            responseData.state = api.convert.stringToBoolean(responseData.state == null ? "true" : responseData.state);
            if (responseData.state) {
                var projects = projectList.querySelector(".projects");
                var innerHTML = projects.innerHTML.replace(RegExp("template", "gi"), "");

                projects.innerHTML = null;
                for (var i in responseData.list) {
                    responseData.list[i].orderBy = param.orderBy == "" ? "" : "&orderBy=" + param.orderBy;
                    if(responseData.list[i].endDate == "1900-01-01")
                        responseData.list[i].endDate = "";

                    projects.innerHTML += convertTemplate.from(innerHTML, responseData.list[i]);
                }
            }

            api.set.event(document.getElementById("doEdit"), "click", function () {
                var param = {
                    page: api.const.page,
                    rfp: location.href.getValueByKey("rfp") ? location.href.getValueByKey("rfp") : api.const.rfp,
                    orderBy: location.href.getValueByKey("orderBy") ? location.href.getValueByKey("orderBy") : ""
                };
                location.href = "/project/?" + api.convert.objectToParameter(param);
            });

            api.printPaging(document.querySelector(".pagination"),api.const.page, responseData.maxCount);
        }
    });
})(this);
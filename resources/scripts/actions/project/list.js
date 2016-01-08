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

    param = {};
    param.role = "getProjectList";
    param.PAGE = api.const.page;
    param.RFP = location.href.getValueByKey("rfp") ? location.href.getValueByKey("rfp") : api.const.rfp;
    param.orderBy = location.href.getValueByKey("orderBy") ? location.href.getValueByKey("orderBy") : "";

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
        }
    });
})(this);
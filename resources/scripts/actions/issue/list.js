(function (root) {
    const issueList = document.getElementById("issueList");
    const URL = "/modules/issue.asp";
    var param = {
        role: "getIssueTotal",
        project: location.href.getValueByKey("project") ? location.href.getValueByKey("project") : "",
        startDate: "",
        endDate: ""
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
                var summary = issueList.querySelector(".summary");
                var innerHTML = summary.innerHTML.replace(RegExp("template", "gi"), "");

                summary.innerHTML = convertTemplate.from(innerHTML, responseData);
            }
            else {
                alert(responseData.message);
            }
        }
    });

    param = {
        role: "getIssueList",
        project: location.href.getValueByKey("project") ? location.href.getValueByKey("project") : "",
        PAGE: api.const.page,
        RFP: location.href.getValueByKey("rfp") ? location.href.getValueByKey("rfp") : api.const.rfp,
        orderBy: location.href.getValueByKey("orderBy") ? location.href.getValueByKey("orderBy") : ""
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
                var issues = issueList.querySelector(".issues");
                var innerHTML = issues.innerHTML.replace(RegExp("template", "gi"), "");

                issues.innerHTML = null;
                for (var i in responseData.list) {
                    responseData.list[i].orderBy = param.orderBy == "" ? "" : "&orderBy=" + param.orderBy;
                    responseData.list[i].isended = responseData.list[i].endDate == "1900-01-01" ? "　" : "end";
                    issues.innerHTML += convertTemplate.from(innerHTML, responseData.list[i]);
                }
                api.printPaging(document.querySelector(".pagination"),api.const.page, responseData.maxCount);
            }

            if(location.href.getValueByKey("project")) {
                api.set.event(document.getElementById("doEdit"), "click", function () {
                    var param = {
                        project: location.href.getValueByKey("project") ? location.href.getValueByKey("project") : "",
                        PAGE: api.const.page,
                        RFP: location.href.getValueByKey("rfp") ? location.href.getValueByKey("rfp") : api.const.rfp,
                        orderBy: location.href.getValueByKey("orderBy") ? location.href.getValueByKey("orderBy") : ""
                    };
                    location.href = "/issue/?" + api.convert.objectToParameter(param);
                });
            }else{
                api.remove.el(document.getElementById("doEdit"));
            }

            api.set.flexHeight(issueList);
        }
    });
})(this);
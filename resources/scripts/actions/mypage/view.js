/**
 * Created by hansollim on 2016-01-05.
 */
(function (root) {
    const mypageView = document.getElementById("mypageView");

    api.ajax({
        type: "GET", url: "/modules/account.asp", data: null, contentType: "application/json;",
        success: function (data) {
            var responseData = JSON.parse(data);
            var part = responseData.userPart ? responseData.userPart : "1";
            var info = mypageView.querySelector(".myInfo .info");
            var innerHTML = info.innerHTML.replace(RegExp("template", "gi"), "");

            info.innerHTML = convertTemplate.from(innerHTML, responseData);

            var param = { role: "getProjectTotal", userId: responseData.userId };
            api.ajax({
                type: "GET", url: "/modules/project.asp", data: param, contentType: "application/json;",
                success: function(data) {
                    var responseData = JSON.parse(data);
                    var exportData = {
                        projectTotal : responseData.total,
                        projectCompleted : responseData.completed,
                        projectProgress : responseData.progress,
                        projectTerminated : responseData.terminated
                    };
                    var project = mypageView.querySelector(".myInfo .cards .project");

                    var innerHTML = project.innerHTML;
                    project.innerHTML = convertTemplate.from(innerHTML, exportData);

                    var graph = project.querySelector(".graph th");
                    var pieData = [
                        {
                            value: responseData.completed,
                            color:"#46BFBD",
                            highlight: "#5AD3D1",
                            label: "완료된 프로젝트"
                        },
                        {
                            value: responseData.progress,
                            color: "#949FB1",
                            highlight: "#A8B3C5",
                            label: "진행중인 프로젝트"
                        },
                        {
                            value: responseData.terminated,
                            color: "#FDB45C",
                            highlight: "#FF5A5E",
                            label: "중단된 프로젝트"
                        }
                    ];
                    api.get.chart(graph, pieData);
                }
            });

            var param = { role: "getIssueTotal", userId: responseData.userId };
            api.ajax({
                type: "GET", url: "/modules/issue.asp", data: param, contentType: "application/json;",
                success: function(data) {
                    var responseData = JSON.parse(data);
                    var exportData = {
                        issueTotal : responseData.total,
                        issueCompleted : responseData.completed,
                        issueProgress : responseData.progress,
                        issueTerminated : responseData.terminated
                    };
                    var issue = mypageView.querySelector(".myInfo .cards .issue");

                    var innerHTML = issue.innerHTML;
                    issue.innerHTML = convertTemplate.from(innerHTML, exportData);

                    var graph = issue.querySelector(".graph th");
                    var pieData = [
                        {
                            value: responseData.completed,
                            color:"#46BFBD",
                            highlight: "#5AD3D1",
                            label: "완료된 이슈"
                        },
                        {
                            value: responseData.progress,
                            color: "#949FB1",
                            highlight: "#A8B3C5",
                            label: "진행중인 이슈"
                        },
                        {
                            value: responseData.terminated,
                            color: "#F7464A",
                            highlight: "#FF5A5E",
                            label: "중단된 이슈"
                        }
                    ];
                    api.get.chart(graph, pieData);
                }
            });

            var param = { role: "getParts" };
            api.ajax({
                type: "GET", url: "/modules/part.asp", data: param, contentType: "application/json;",
                success: function (data) {
                    var responseData = JSON.parse(data);
                    responseData.state = api.convert.stringToBoolean(responseData.state == null ? "true" : responseData.state);
                    if (responseData.state) {
                        var select = mypageView.querySelector("#part");
                        var option = null, list = null, i;

                        select.innerHTML = "";
                        for (i in responseData.list) {
                            list = responseData.list[i];
                            option = document.createElement("option");
                            option.value = list.idx;
                            option.innerText = list.name;
                            if (list.idx == part)
                                option.selected = true;
                            select.appendChild(option);
                        }
                    }
                    else {
                        alert(responseData.message);
                    }
                }
            });

            api.set.event(document.getElementById("doEdit"), "click", function (e) {
                var param = {
                    role: "updateUser",
                    userid: api.user.userId,
                    part: mypageView.querySelector("#part").value,
                    password: mypageView.querySelector("input[name=password]").value
                };
                if (confirm("변경 하시겠습니까?")) {
                    api.ajax({
                        type: "GET", url: "/modules/user.asp", data: param, contentType: "application/json;",
                        success: function (data) {
                            var responseData = JSON.parse(data);
                            responseData.state = api.convert.stringToBoolean(responseData.state == null ? "true" : responseData.state);
                            if (responseData.state) {
                                param = {role: "logout"};
                                api.ajax({
                                    type: "GET",
                                    url: "/modules/account.asp",
                                    data: param,
                                    contentType: "application/json;",
                                    success: function (data) {
                                        var responseData = JSON.parse(data);
                                        alert("정보가 변경되었습니다. 다시 로그인해주세요.");
                                        location.href = "/";
                                    }
                                });
                            }
                            else {
                                alert(responseData.message);
                            }
                        }
                    });
                }
            });
        }
    });

})(this);
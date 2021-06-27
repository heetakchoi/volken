
// 파라메터 처리 시작
var upper = 0;
const urlSearchParams = new URLSearchParams(window.location.search);
const params = Object.fromEntries(urlSearchParams.entries());
for (let one in params){
    if(one === "upper"){
        upper = params[one];
    }
}
// 파라메터 처리 종료

// 초기화 시작
function api_list_articles(upper, callback_func){
    var xhr = new XMLHttpRequest();
    xhr.addEventListener("load", callback_func);
    xhr.open("GET", `ListArticles.cgi?upper=${upper}`);
    xhr.send();
}
function api_get_article(srno, callback_func){
    var xhr = new XMLHttpRequest();
    xhr.addEventListener("load", callback_func);
    xhr.open("GET", `ViewArticle.cgi?srno=${srno}`);
    xhr.send();
}
var detail_srno;
function make_detail_view(){
    // 본문이 들어 있을 것으로 기대하고 toggle 클래스를 가진 toggle_element 를 모두 가져와 본다.
    let detail_list = document.querySelectorAll(".toggle");
    // 같은 srno 를 가진 것 뒤에 detail 를 붙인다.
    for(let one_detail of detail_list){
	if(one_detail.dataset.srno == detail_srno){
	    const json_data = JSON.parse(this.responseText);
	    let one_li = one_detail.parentElement;

	    let view_div = document.createElement("div");
	    view_div.className = "detail";

	    // let title_div = document.createElement("div");
	    // title_div.innerHTML = json_data.title;
	    // view_div.append(title_div);

	    // let created_div = document.createElement("div");
	    // created_div.innerHTML = json_data.created;
	    // view_div.append(created_div);

	    let content_div = document.createElement("div");
	    content_div.innerHTML = json_data.content;
	    view_div.append(content_div);


	    one_li.append(view_div);
	}
    }
}

function toggle_detail_view(event){
    // toggle_element - 열기/닫기 가 클릭되면 상태에 따라
    // detail_view 를 만들어 붙이기 위해 make_detail_view 를 호출하거나
    // detail_view 를 지워버린다.
    let span_element = event.target;
    let srno = event.target.dataset.srno;
    detail_srno = srno;
    let status = event.target.dataset.status;
    if(status == "expand"){
	span_element.innerHTML = "닫기";
	event.target.dataset.status = "collapse";
	api_get_article(srno, make_detail_view);
    }else{
	span_element.innerHTML = "열기";
	event.target.dataset.status = "expand";
	for (let child_element of span_element.parentElement.children){
	    if(child_element.className == "detail"){
		child_element.remove();
	    }
	}
    }
}
function make_list_view(){
    // article 이 붙는 최 상단 element
    const article_container = document.querySelector("#article-content");
    // api_list_articles 에서 비 동기로 호출한 article 리스트 결과를 가져온다
    const json_data = JSON.parse(this.responseText);
    json_data.forEach(
	(item, index)=>{
	    let one_article_element = document.createElement("div");
	    one_article_element.className = "article";

	    let created_element = document.createElement("span");
	    created_element.className = "created";
	    created_element.innerHTML = item.created;
	    one_article_element.append(created_element);

	    let title_element = document.createElement("span");
	    title_element.className = "title";
	    title_element.innerHTML = item.title;
	    one_article_element.append(title_element);

	    let toggle_element = document.createElement("span");
	    toggle_element.className = "toggle";
	    toggle_element.innerHTML = "열기";
	    toggle_element.setAttribute("data-srno", item.srno);
	    toggle_element.setAttribute("data-status", "expand");
	    toggle_element.addEventListener("click", toggle_detail_view);
	    one_article_element.append(toggle_element);

	    article_container.append(one_article_element);
	    upper = item.srno;
	}
    );
    return;
}
api_list_articles(0, make_list_view);
// 초기화 종료

//  more button 처리 시작
function more_articles(){
    api_list_articles(upper, make_list_view);
}
const more_button_list = document.querySelectorAll(".more-button");
for( let more_button of more_button_list){
    more_button.addEventListener("click", more_articles);
}
//  more button 처리 종료

// view 처리 시작
const toggle_element_list = document.querySelectorAll(".toggle");
for( let toggle_element of toggle_element_list){
    toggle_element.addEventListener("click", toggle_detail_view);
}
// view 처리 끝
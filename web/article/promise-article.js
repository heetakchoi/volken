// 파라메터 처리 시작
let upper = 0;
const urlSearchParams = new URLSearchParams(window.location.search);
const params = Object.fromEntries(urlSearchParams.entries());
for (let one in params){
    if(one === "upper"){
        upper = params[one];
    }
}
// 파라메터 처리 종료

// Promise XmlHttpRequest 시작
function promiseXHR(obj){
    return new Promise((resolve, reject)=>{
	let xhr = new XMLHttpRequest();
	xhr.open(obj.method || "GET", obj.url);
	if(obj.headers){
	    Object.keys(obj.headers).forEach(key=>{
		xhr.setRequestHeader(key, obj.headers[key]);
	    });
	}
	xhr.onload = () => {
	    if(xhr.status >= 200 && xhr.status < 300){
		resolve(xhr.response);
	    }else{
		reject(xhr.statusText);
	    }
	};
	xhr.onerror = () => reject(xhr.statusText);
	xhr.send(obj.body);
    });
}
// Promise XmlHttpRequest 종료

function fetch_one_article(srno){
    let param = new Object();
    param.url = `ViewArticle.cgi?srno=${srno}`;
    param.method = "GET";
    promiseXHR(param)
	.then(data => {
	    // 본문이 들어 있을 것으로 기대하고 toggle 클래스를 가진 toggle_element 를 모두 가져와 본다.
	    let detail_list = document.querySelectorAll(".toggle");
	    // 같은 srno 를 가진 것 뒤에 detail 를 붙인다.
	    for(let one_detail of detail_list){
		if(one_detail.dataset.srno == srno){
		    const json_data = JSON.parse(data);
		    let one_article = one_detail.parentElement;

		    let view_div = document.createElement("div");
		    view_div.className = "detail";

		    let content_div = document.createElement("div");
		    let content = json_data.content;
		    content.replace(/\\\\/g, "\\");
		    content_div.innerHTML = content;
		    view_div.append(content_div);

		    one_article.append(view_div);
		    break;
		}
	    }
	}).catch(error=>{
	    console.log(error);
	}).finally(function(){
	    MathJax.typeset();
	});
    return;
}
function toggle_detail_view(event){
    // toggle_element - 열기/닫기 가 클릭되면 상태에 따라
    // detail_view 를 만들어 붙이기 위해 make_detail_view 를 호출하거나
    // detail_view 를 지워버린다.
    let span_element = event.target;
    let srno = event.target.dataset.srno;
    let status = event.target.dataset.status;
    if(status == "expand"){
	span_element.innerHTML = "닫기";
	event.target.dataset.status = "collapse";
	fetch_one_article(srno);
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
function fetch_articles(arg_upper){
    let param = new Object();
    param.url = `ListArticles.cgi?upper=${arg_upper}`;
    param.method = "GET";
    promiseXHR(param)
	.then(data => {
	    // article 이 붙는 최 상단 element
	    const article_container = document.querySelector("#article-content");
	    // api_list_articles 에서 비 동기로 호출한 article 리스트 결과를 가져온다
	    const json_data = JSON.parse(data);
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
		    let title = item.title;
		    title.replace(/\\\\/g, "\\");
		    title_element.innerHTML = title;
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
	}).catch(error=>{
	    console.log(error);
	}).finally(()=>{
	    MathJax.typeset();
	});
    return;
}

// 초기화 시작
fetch_articles(0);
// 초기화 종료

//  more button 처리 시작
function more_articles(){
    fetch_articles(upper);
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

<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>


</head>
<body>
	<div id="map" style="width: 100%; height: 350px;"></div>

	<button onclick="resizeMap()">지도 크기 바꾸기</button>
	<br>
	<button onclick="myLocation()">내위치</button>
	<button onclick="appendMarker(inform.driver1)">기사1</button>
	<button onclick="appendMarker(inform.driver2)">기사2</button>
	<button onclick="appendMarker(inform.driver3)">기사3</button>
	<button onclick="appendMarker(inform.driver4)">기사4</button>
	<br>
	<button onclick="setBounds()">마커 한 화면 보이기</button>
	<br>
	<button onclick="showInfowindows()">인포윈도우 열기</button>
	<br>
	<button onclick="hideInfowindows()">인포윈도우 닫기</button>
	<br>
	<a id="start-navigation" href="javascript:kakaoNavi()">
	  <img src="https://developers.kakao.com/assets/img/about/buttons/navi/kakaonavi_btn_medium.png"
	    alt="길 안내하기 버튼" />
	</a>
</body>
<!-- body 밑에 있어야 맵이 작동! -->
<script type="text/javascript"
	src="//dapi.kakao.com/v2/maps/sdk.js?appkey=appkey&libraries=services"></script>

<script src="https://t1.kakaocdn.net/kakao_js_sdk/2.3.0/kakao.min.js"
  integrity="sha384-70k0rrouSYPWJt7q9rSTKpiTfX6USlMYjZUtr1Du+9o4cGvhPAWxngdtVZDdErlh" crossorigin="anonymous"></script>
<script>
  Kakao.init('appkey'); // 사용하려는 앱의 JavaScript 키 입력
</script>

<script>
// 기사 정보
const inform = {
		driver1:[
			{
				name:'위치1',
				address:'서울특별시 강남구 논현로145길 40-8',
				example:{
					test1:'test1',
					test2:'test2',
					test3:'test3',
				}
			},
			{
				name:'위치2',
				address:'서울특별시 강남구 도산대로 102'
			},
			{
				name:'위치3',
				address:'서울 강남구 논현로149길 73 1층 달수네 소곱창'
			},
			{
				name:'위치4',
				address:'서울특별시 강남구 도산대로11길 29'
			}
		],
		driver2:[
			{
				name:'위치1',
				address:'서울 강남구 압구정로2길 46 강남상가아파트'
			},
			{
				name:'위치2',
				address:'서울 강남구 도산대로17길 13'
			},
			{
				name:'위치3',
				address:'서울 강남구 도산대로8길 13 1층'
			},
			{
				name:'위치4',
				address:'서울 강남구 논현동 26'
			},
			{
				name:'위치5',
				address:'서울 강남구 도산대로 158'
			}
		],
		driver3:[
			{
				name:'위치1',
				address:'서울 강남구 논현동 137-18'
			},
			{
				name:'위치2',
				address:'서울 강남구 논현로123길 19'
			},
			{
				name:'위치3',
				address:'서울 강남구 역삼동 663-19'
			},
			{
				name:'위치4',
				address:'서울 강남구 강남대로120길 33'
			},
			{
				name:'위치5',
				address:'서울 강남구 논현동 162-11'
			}
		],
		driver4:[
			{
				name:'위치1',
				address:'서울 강남구 학동로 지하 346'
			},
			{
				name:'위치2',
				address:'서울 강남구 선릉로120길 14 3층'
			},
			{
				name:'위치3',
				address:'서울 강남구 봉은사로 447'
			},
			{
				name:'위치4',
				address:'서울 강남구 삼성로103길 12'
			},
			{
				name:'위치5',
				address:'서울 강남구 영동대로 643'
			},
			{
				name:'위치6',
				address:'서울 강남구 청담동 66'
			},
			{
				name:'위치7',
				address:'서울 강남구 선릉로148길 38'
			}
		]
};


/* 카카오맵 상수 */
var mapContainer = document.getElementById('map'), // 지도를 표시할 div
        mapOption = {
          center: new kakao.maps.LatLng(33.450701, 126.570667), // 지도의 중심좌표
          level: 3 // 지도의 확대 레벨
        };
// 지도를 생성합니다
var map = new kakao.maps.Map(mapContainer, mapOption);
// 주소-좌표 변환 객체를 생성합니다
var geocoder = new kakao.maps.services.Geocoder();
// 지도를 재설정할 범위정보를 가지고 있을 LatLngBounds 객체를 생성합니다 -> 마커가 한눈에 보이게 지도의 중심좌표와 레벨을 재설정
var bounds = new kakao.maps.LatLngBounds();   
// 현재 기사 정보 상수
var currentData = null;
// 마커 표기를 위한 배열
var markers = [];
// infowindows 표기를 위한 배열
var infowindows= [];


// 지도를 표시하는 div 크기를 변경하는 함수입니다
function resizeMap() {
    var mapContainer = document.getElementById('map');
    if(mapContainer.style.width === '100%') {
    	mapContainer.style.width = '700px';
    	mapContainer.style.height = '700px';
	} else {
		mapContainer.style.width = '100%';
    	mapContainer.style.height = '350px';
	}
    relayout();
}
// 지도를 표시하는 div 크기를 변경한 이후 지도가 정상적으로 표출되지 않을 수도 있습니다
// 크기를 변경한 이후에는 반드시  map.relayout 함수를 호출해야 합니다 
// window의 resize 이벤트에 의한 크기변경은 map.relayout 함수가 자동으로 호출됩니다
function relayout() {
	// 지도 변경 후 새로운 맵의 크기에 맞게 정보를 다시 불러오기
	if(currentData !== null){
		appendMarker(currentData);
	}
  
    map.relayout();
} 

// 마커 보이기
function appendMarker(driver) {
	// 지도 크기 변경시 현재 기사 정보 넘기기 위해 전역변수 설정
	currentData = driver;
	
	// 맵에 찍힌 마커와 인포 윈도우 초기화
	markerReset();
	
	// 지도 재설정 범위 정보 초기화
	bounds = new kakao.maps.LatLngBounds(); 
	// 센터 좌표 정보
	var centerX = 0;
	var centerY = 0;
	//Promise 배열
	var promises = [];
	
	//좌표 변환 및 마커 생성
	driver.forEach((currentElement, index, array) => {
	    console.log(index);
	    console.log(currentElement);
	    
	    var promise = new Promise(function(resolve, reject) {
			// 주소로 좌표를 검색
			geocoder.addressSearch(currentElement.address, function(result, status) {
				// 정상적으로 검색이 완료됐으면 if문 실행
				if (status === kakao.maps.services.Status.OK) {
					
					// 마커가 표시될 위치입니다 
					var coords = new kakao.maps.LatLng(result[0].y, result[0].x);
					
					//console.log('index:'+index);
					//console.log('coords:'+coords);
					
					// 센터값 계산을 위한 덧셈
					centerX += Number(result[0].x);
					centerY += Number(result[0].y);
					
					// 결과값으로 받은 위치로 마커와 인포 윈도우 생성 및 저장(인포윈도우로 장소에 대한 설명을 표시)
				    markerSave(coords, currentElement.name);
					
					// 모든 마커 표시를 위한 좌표 저장
					bounds.extend(coords);

					resolve(" index"+index+" 성공");
				}
			});
	    });
	    promises.push(promise);
	});
	
	//비동기인 geocoder.addressSearch 함수가 끝나고 실행
	Promise.all(promises).then(
		(test) => {
    		centerMarker(driver, centerX, centerY);
			console.log("PromiseTest:"+test)
		}
	);
}

// 중심 마커와 인포윈도우 생성 후 모든 마커와 인포윈도우 표시, 중심좌표로 화면 보여주기
function centerMarker(driver, centerX, centerY) {
	// 마커가 표시될 위치입니다 
	var centerPosition  = new kakao.maps.LatLng(centerY/driver.length,centerX/driver.length); 
	var message = 'Center';
	
	//console.log('centerPosition:'+centerPosition);

	// 마커와 인포 윈도우 생성 및 저장
    markerSave(centerPosition, message);
   	// 마커와 인포윈도우 찍기, 중심좌표로 화면 이동
   	putOnLocation(centerPosition);
}

// 내위치 찍기 함수
function myLocation() {
	
	// 지도 재설정 범위 정보 초기화
	bounds = new kakao.maps.LatLngBounds(); 
	// 맵에 찍힌 마커와 인포 윈도우 초기화
	markerReset();
	
	// HTML5의 geolocation으로 사용할 수 있는지 확인
	if (navigator.geolocation) {
	    // GeoLocation을 이용해서 접속 위치를 얻기
	    navigator.geolocation.getCurrentPosition(function(position) {
	        
	    	// geolocation 위치 정보
	        var lat = position.coords.latitude, // 위도
	            lon = position.coords.longitude; // 경도
	        
	        // 내 위치 좌표
	        var locPosition = new kakao.maps.LatLng(lat, lon); // 마커가 표시될 위치를 geolocation으로 얻어온 좌표로 생성합니다
	     	// 인포윈도우 메세지
		    var message = '여기에 계신가요?!';
	       
	        // 내위치 확인 문구
		    var myPoint = "myPoint";
	        
		 	// 마커와 인포 윈도우 생성 및 저장
		    markerSave(locPosition, message, myPoint);
	       	// 마커와 인포윈도우 찍기, 중심좌표로 화면 이동
	       	putOnLocation(locPosition);
	      });
	    
	} else { // HTML5의 GeoLocation을 사용할 수 없을때 마커 표시 위치와 인포윈도우 내용을 설정합니다
		// 임시 위치 좌표(변경해야됨)
	    var locPosition = new kakao.maps.LatLng(33.450701, 126.570667);
		// 인포윈도우 메세지
	    var message = 'geolocation을 사용할수 없어요..';
	    
	    // 마커와 인포 윈도우 생성 및 저장
	    markerSave(locPosition, message);
       	// 마커와 인포윈도우 찍기, 중심좌표로 화면 이동
       	putOnLocation(locPosition);
	}
}

// 맵에 찍힌 마커와 인포 윈도우 초기화
function markerReset() {
	// 맵에 찍힌 마커들이 있으면 삭제 없으면 통과
	if(markers.length >= 1){
		markers.forEach((currentElement, index, array) => {
			currentElement.setMap(null);
    	});
	}
	// 마커 배열을 빈 배열로 만들기
	markers = [];
	
	// 맵에 찍힌 인포윈도우들이 있으면 삭제 없으면 통과
	if(infowindows.length >= 1){
		hideInfowindows();
	}
	// 인포윈도우 배열을 빈 배열로 만들기
	infowindows = [];
}

// 머커와 인포 윈도우 저장
function markerSave(locPosition, message, myPoint) {
	// 내 위치 찍기인지 아닌지 체크
	if(myPoint === "myPoint") {
		var imageSrc = 'https://cdn.icon-icons.com/icons2/1320/PNG/512/-location_86865.png', // 마커이미지의 주소입니다    
	    imageSize = new kakao.maps.Size(54, 55), // 마커이미지의 크기입니다
	    imageOption = {offset: new kakao.maps.Point(27, 52)}; // 마커이미지의 옵션입니다. 마커의 좌표와 일치시킬 이미지 안에서의 좌표를 설정합니다.
	      
	    //마커의 이미지정보를 가지고 있는 마커이미지를 생성합니다
	    var markerImage = new kakao.maps.MarkerImage(imageSrc, imageSize, imageOption);
		
		// 마커를 생성
	   	var marker= new kakao.maps.Marker({
	   		position: locPosition,
	   		image: markerImage,
	   		clickable: true
	   	});
		
	 	// 마커 저장  
	   	markers.push(marker);
	  	
		// 마커의 인포윈도우 생성
	   	var infowindow = new kakao.maps.InfoWindow({
	   		content: '<div style="width:150px;text-align:center;padding:6px 0;">'+message+'</div>'
	   	});
	   	// 인포윈도우 저장
	   	infowindows.push(infowindow);
	   	
	} else {
		// 마커를 생성
	   	var marker = new kakao.maps.Marker({
	   		position: locPosition,
	   		clickable: true
	   	});
		// 마커 저장  
	   	markers.push(marker);
		
	    // 내비 연동!
	    var naviMessage = '';
	    naviMessage += '<div style="width:150px;text-align:center;padding:6px 0;">';
	    naviMessage += message + '</div>';
	    if(message !== 'Center'){
		    naviMessage += '<a id="start-navigation" href="javascript:markerNavi('+ locPosition.La +', '+locPosition.Ma+')">';
		    naviMessage += '	<img src="https://developers.kakao.com/assets/img/about/buttons/navi/kakaonavi_btn_medium.png" alt="길 안내하기 버튼" />';
		    naviMessage += '</a>';
	    }
	    
	 	// 마커의 인포윈도우 생성
	   	var infowindow = new kakao.maps.InfoWindow({
	   		content: naviMessage
	   	});
	   	// 인포윈도우 저장
	   	infowindows.push(infowindow);
	}
	
	//마커에 클릭이벤트를 등록합니다
	kakao.maps.event.addListener(marker, 'click', function() {
		// 모든 인포윈도우 닫기(인포윈도우 한개만 오픈되게하기 위해)
		hideInfowindows(); 
		
	    // 마커 위에 인포윈도우를 표시합니다
	    infowindow.open(map, marker);  
	});
}

// 맵 클릭하면 모든 인포윈도우 닫기
kakao.maps.event.addListener(map, 'click', function(mouseEvent) {
	hideInfowindows(); 
});

// 마커와 인포 윈도우 찍기
function putOnLocation(locPosition) {
	// 마커와 인포 윈도우 찍기
	for (var i = 0; i < markers.length; i++) {
		markers[i].setMap(map);
		infowindows[i].open(map, markers[i]);
	}
	
	// 지도 중심좌표를 접속위치로 변경합니다
    map.setCenter(locPosition);
}
 
//마커 한 화면에 보이게 하기
function setBounds() {
	if(bounds.ha !== Infinity){
		// LatLngBounds 객체에 추가된 좌표들을 기준으로 지도의 범위를 재설정합니다
	    // 이때 지도의 중심좌표와 레벨이 변경될 수 있습니다
	    map.setBounds(bounds);
	}
}

// 모든 인포윈도우 닫기
function hideInfowindows() {
	infowindows.forEach((currentElement, index, array) => {
		currentElement.close();
	});    
}

// 모든 인포윈도우 열기
function showInfowindows() { 
	// 마커와 인포 윈도우 찍기
	for (var i = 0; i < markers.length; i++) {
		infowindows[i].open(map, markers[i]);
	}   
}

//카카오내비 실행 테스트
function kakaoNavi() {
	Kakao.Navi.start({
		  name: '현대백화점 판교점',
		  x: 127.11205203011632,
		  y: 37.39279717586919,
		  coordType: 'wgs84',
		});
}

//카카오내비 실행 테스트
function markerNavi(coordinateX, coordinateY) {
	
	//console.log(coordinateX);
	//console.log(coordinateY);
	
	Kakao.Navi.start({
		  name: '현대백화점 판교점',
		  x: coordinateX,
		  y: coordinateY,
		  coordType: 'wgs84',
		});
}



</script>
</html>

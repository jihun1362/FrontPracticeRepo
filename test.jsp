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
	<button onclick="appendMarker(inform.driver1)">기사1</button>
	<button onclick="appendMarker(inform.driver2)">기사2</button>
	<button onclick="appendMarker(inform.driver3)">기사3</button>
	<button onclick="appendMarker(inform.driver4)">기사4</button>
	<br>
	<button onclick="setBounds()">마커 한 화면 보이기</button>
	<button onclick="hideInfowindows()">인포윈도우 닫기</button>

</body>
<!-- body 밑에 있어야 맵이 작동! -->
<script type="text/javascript"
	src="//dapi.kakao.com/v2/maps/sdk.js?appkey=076bc91809407fe07291974850261b9a&libraries=services"></script>
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
		infowindows.forEach((currentElement, index, array) => {
			currentElement.close();
    	});
	}
	// 인포윈도우 배열을 빈 배열로 만들기
	infowindows = [];
	
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
	
					// 결과값으로 받은 위치로 마커 생성
					var marker = new kakao.maps.Marker({
						position: coords
					});
					// 마커 저장
					markers.push(marker);
	
					// 인포윈도우로 장소에 대한 설명을 표시
					var infowindow = new kakao.maps.InfoWindow({
						content: '<div style="width:150px;text-align:center;padding:6px 0;">'+currentElement.name+'</div>'
					});
					// 인포윈도우 저장
					infowindows.push(infowindow);
					
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
	
	//console.log('centerPosition:'+centerPosition);
	
	// 센터마커를 생성
	var centerMarker= new kakao.maps.Marker({
		position: centerPosition
	});
   	// 센터마커 저장  
	markers.push(centerMarker);
	
	// 센터 마커의 인포윈도우 생성
	var infowindow = new kakao.maps.InfoWindow({
		content: '<div style="width:150px;text-align:center;padding:6px 0;">Center</div>'
	});
	// 인포윈도우 저장
	infowindows.push(infowindow);
   	
   	// 마커 및 인포윈도우들을 표시
	for (var i = 0; i < markers.length; i++) {
		markers[i].setMap(map);
		infowindows[i].open(map, markers[i]);
	} 
   	
   	// 해당 위치를 중심으로 보여주기
	map.setCenter(centerPosition);
}

// 마커 한 화면에 보이게 하기
function setBounds() {
	if(bounds.ha !== Infinity){
		// LatLngBounds 객체에 추가된 좌표들을 기준으로 지도의 범위를 재설정합니다
	    // 이때 지도의 중심좌표와 레벨이 변경될 수 있습니다
	    map.setBounds(bounds);
	}
}

// 인포윈도우 닫기
function hideInfowindows() {
	infowindows.forEach((currentElement, index, array) => {
		currentElement.close();
	});    
}
</script>
</html>
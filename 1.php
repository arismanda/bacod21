<html>
<head>
<body>

<div id="app">
  <table class="table table-bordered">
    <tr>
      <th>Absen</th>
      <th>Tgl 1</th>
      <th>Tgl 2</th>
      <th>Tgl 3</th>
    </tr>
	
    <tbody id="data">
    </tbody>
  </table>
</div>
<script>
var mF = {
	data: [],
	init: function(){
  	this.setData();
  },
  setData: function(){
    this.data.push([1,'Ane', 'Sakit', '2-november-2019',]);
    this.data.push([2,'Sakit', 'Sakit', '3-november-2019',]);
    this.data.push([3,'Cuk', 'Sakit', '1-november-2019',]);

    
    this.createTable();
  },
  createTable: function(){
  	var ins = document.getElementById("data");
    for(var i = 0; i < this.data.length; i++){
  	var app = document.createElement("tr");
    	for(var j = 0; j < this.data[i].length; j++){
      	if(j == 3){
        	var gD = new Date(this.data[i][j]);
          var mD = gD.getDate();
          for(var k = 1; k <= this.data.length; k++){
          	if(k == mD){
            	var inp = document.createElement("td");
            	inp.innerHTML = this.data[i][2];
            	app.appendChild(inp);
            } else {
            	var dt = document.createElement("td");
              app.appendChild(dt);
            }
          }
        }
        else if(j == 1) {
        	var nm = document.createElement("td");
          nm.innerHTML = this.data[i][1];
          app.appendChild(nm);
        }
      }
      ins.appendChild(app)
    }
  }
}

mF.init();
</script>
</body>
</head>
</html>
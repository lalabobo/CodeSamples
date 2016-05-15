// setup the empty canvas svg
var w = document.getElementById('chart').clientWidth;//1000;
var h = 600;
var margin = {top: h*0.05, right: w*0.3, bottom: h*0.1, left: w*0.05}
var canvas = d3.select("#chart")  // select: locate one element; selectAll: locate multiple element (e.g., a class that has multiple elements). Here we locate the div with id = chart
               .append("svg")
               .attr("width",w)
               .attr("height",h);
var legendCircleSize = w*0.006;
var legendSpacing = h*0.035;
var height = legendCircleSize + legendSpacing
var legendMargin = w*0.05


// ---------------------------------  read in json data  ----------------------------------
$(document).ready(function() { // wait for the page (i.e. html) fully loaded for manipulation
 // everything that will use the data has to be wrap into d3.json
 d3.json("http://felicity.v1.pe/generated/chartJSON/data/game/glmnet_imp.json",function(error,data){

    // ------------------ 1. remove NA/NULL and convert numeric from string ------------------
    // by default, everything will be parsed as string
    var dataCleaned = [];
    data.forEach(function(d,i){ // if min or coef has NaN, remove that record
      if (isNaN(d.min) || isNaN(d.coef)) {
          return true   // use "return true " to exit one forEach iteration. if "return false", exit and stop the forEach completely
      }
      d.min = +d.min; // using "+" to coerce into number
      d.coef = +d.coef;
      dataCleaned.push(d);
    });
    data = dataCleaned; 
    console.log(data);


    // ------------------- 3. pull filter buttons labels from all data ------------------------
    // grab all distinct variable_clean and sort them
    //var label = [];
    function unique(data,target){  // input: dataset, which column of the dataset to pull distinct values from
      var label = [];  // output array with unique value in it
      // given data = [{variable_clean: 'sum_level'},{variable_clean:'totalGold''}];
      // loop through them
      for(i = 0;i<data.length;i++){
        // check to make sure label doesn't already contain this iteration of variable_clean
        if (typeof(data[i][target]) != 'undefined' && label.indexOf(data[i][target]) === -1) {  // -1 means not found so we can ensure unique here
            // it doesn't so we can add it.
            label.push(data[i][target]);
        }
      }
      label = label.sort(); // sort the variable names
      return(label)
    }

    c = unique(data,"TypeOfVariable"); // grab the unique values from TypeOfVariable column (e.g., game play, champi

    // change the filter button colours based on events
    function colourChange(elmId,trigger){
        if (trigger == 'click'){
            document.getElementById(elmId).style.backgroundColor = '#3399CC';
            document.getElementById(elmId).style.color = '#FFFFFF';
        }
        if (trigger == 'initial'){
            document.getElementById(elmId).style.backgroundColor = '#C2C2C2';
            document.getElementById(elmId).style.color = '#FFFFFF';
        }
    }
    
    // assign values to display in the filter buttons 
    function initiateOption(array,elmId){ //input: unique valeus, elementId in the html
        for(i = 0; i < array.length; i++){
            document.getElementById(elmId + (i+1)).innerHTML = array[i];  // assign the unique value to each element in the html
            colourChange((elmId + (i+1)),'initial');
        }
    }

    initiateOption(c,'TypeOfVariable');
    
    // -------------------------------- 4. apply the chain effect of filtering -------------------------
    // The chain effect of filtering is like this:
        // click a filter button -> 
        // trigger button colour change -> 
        // pass down the button value & trigger data filtering ->
        // trigger chart redraw
        
    // The default setting would follow a similar chain
    // apply default colour schemes and data filtering
    defaultValue = 'Game Play';
    baseId = 'TypeOfVariable';
    // 1. apply colours to the default selection
    var numChildren = c.length;  // calculate the number of children tag in html
    // give every child the initial format
    for(i = 1;i < (numChildren); i++){  // start from 1 because one of the children is <p>. We're interested in the number of buttons here
        colourChange((baseId + i),'initial');  // give buttons the initial colour
    };
    // assign the selected one the 'click' format
    colourChange((baseId + (c.indexOf(defaultValue)+1)),'click'); // the index starts from 0 but the the # in id starts from TypeOfVariable1
    // 2. data filtering
    currentData = data.filter(filterCriteria(baseId,defaultValue));
    // 3. draw the line chart
    redraw(currentData);
    
    
    // click a filter button to trigger colour change, data filtering, and chart redraw
    // make this function available in window global for html to access
    window.update = function(s){ // s is the element that is clicked
        // 1. trigger colour change
        var baseId = s.id.replace(/[0-9]+/,''); // remove the number to grab the baseId. e.g., TypeOfVariable1 -> TypeOfVariable
        var numChildren = document.getElementById(s.id).parentElement.children.length;  // calculate the number of children tag in html
        // give every child the initial format
        for(i = 1;i < (numChildren); i++){  // start from 1 because one of the children is <p>. We're interested in the number of buttons here
            colourChange((baseId + i),'initial');  // give buttons the initial colour
        }
        // assign the selected one the 'click' format
        colourChange(s.id,'click');
        
        // 2. trigger data filtering based on the button value
        value = document.getElementById(s.id).innerHTML;  // this has to happen after initiateOption() is called
        currentData = data.filter(filterCriteria(baseId,value));  // data is from the mother scope - the json data layer

        // 3. trigger chart redraw
        redraw(currentData);
    }
    
    // filter data based on the value of a variable. e.g., TypeOfVariable = 'Game Play'
    function filterCriteria(variable,value) {
        return function(row) { // feed in each row/obj from data. The filter function loops through each row/obj of data
            return row[variable] == value;
        }
    }


    
    // ----------------- 5. draw the line chart  ---------------
    // all the drawing code will be in here
    function redraw(currentData){
    
    canvas.selectAll("*").remove();    // clean out everything on the canvas
    // 5.1 Scaling based on currentData
    // setup scales for charting. Input: domain; Output: range
    var xscale = d3.scale.linear()
                         .domain([d3.min(currentData,function(d) {return d.min;}) - 0.5,d3.max(currentData,function(d) {return d.min;})])  // - 0.5 here is so x-axis = 1 won't align with y-axis
                         .range([margin.left,w-margin.right]);

    var yscale = d3.scale.linear()
                         //.domain([0,50])
                         .domain([d3.max(currentData,function(d) {return d.coef;}),d3.min(currentData,function(d) {return d.coef;})])  // set the max domain to be max from the dataset
                         .range([margin.top,h-margin.bottom]);
        
    // 5.2 prepare dataset in the format for charting
    // each variable's all time serie data will be stored as 1 obj. e.g., totalGold is array[8], each obj includes:
    // TypeOfVariable:    "Game Play"
    // max.abs_coef.:  0.0145
    // max.coef.:   0.0145
    // min: 1
    // coef:    14

    // assign each variable into an array
    var dataset = [];
    v = unique(currentData,"variable_clean"); // grab the unique values from variable_clean column (e.g., totalGold, sum_level)
   
    for(i = 0; i < v.length; i++){
      variable = v[i];
      // create something like "var sum_level = bla bla"
      // window[] is a global key-value pair container, having info such as window.height = 1000
      // here is to add more key-value pair to the window[] global container
      window[variable] = currentData.filter(function(d){
        return (d.variable_clean == variable)
      })
      dataset.push(window[variable]);  // create an array object that contain the array of each individual variable
    }
    
    // 5.3 define the line chart based on the data object
    // hasn't given any data yet
    var line = d3.svg.line()
                 .interpolate("basis") // make the line smoother
                 .x(function(d) { return xscale(d.min); })
                 .y(function(d) { return yscale(d.coef);});
    
    
    // 5.4 choose 20 colour catories palette             
    var colours = d3.scale.category20();

    // 5.5 draw the line chart 
    // draw the lines (parse in the data and colours)
    // mouseover to highlight the selected line
    var drawLine = canvas.selectAll("path")   
                         .data(dataset) // each is a series
                         .enter()
                         .append("path")
                         .attr("class","line")
                         .attr("d",function(d){
                            return line(d);}) // draw each series
                         .attr("stroke",function(d,i){
                            return colours(i);
                         })  // need this for the line to show
                         .attr("stroke-width",2)
                         .attr("stroke-dasharray",function(d){
                             //for (i==0;i<d.length;i++){
                             //    console.log("d = " + d[i].sign)
                             //    if (d[i].sign == '-'){
                             //        return '5 5';
                             //    }
                             //}
                        })
                         .attr("fill","none")
                         .style('opacity', 1)
                         .on("mouseover",function(d){
                            d3.select(this)
                              .style("stroke-width",'4px');
                            // also highlight the corresponding legend of the selected line based on id
                            var f = document.getElementById(d3.select(this)[0][0].id.replace("-line","-legend"));
                            d3.select(f)
                              .style("font-size", '18px')
                              
                         })
                         .on("mouseleave",function(d){
                            d3.select(this)
                              .style("stroke-width",'2px');
                            // also highlight the corresponding legend of the selected line based on id
                            var f = document.getElementById(d3.select(this)[0][0].id.replace("-line","-legend"))
                            d3.select(f)
                              .style("font-size", '12px')
                              
                         })
        
        //drawline.exit().remove();
        
    // 5.6 animate the lines
    drawLine.each(function(d) { d.totalLength = this.getTotalLength(); })  // because each line has different total length, needs to grab the total length and apply to each line
        .attr("stroke-dasharray", function(d) { return d.totalLength + " " + d.totalLength; })  // stroke-dasharray let you specify the length of the rendered part of the line, then the length of the gap 
        .attr("stroke-dashoffset", function(d) { return d.totalLength; })   // stroke-dashoffset lets you change where the dasharray starts.
        .transition()  // transite to show no line to the full line
        .duration(3000)
        .ease("linear")
        .attr("stroke-dashoffset", 0) // show the whole path
        .attr('id', function(d,i) { return (d[0].variable_clean + "-line"); });
    
    
    // 5.7 legend 
    // define legend (what it is like and what effects it has) and append it as part of the chart
    var legend = canvas.selectAll(".legend")
          .data(dataset)
          .enter()
          .append("g")
          .attr("class", "legend")
          .style('opacity', 1)
          .attr("id", function(d,i){
              return (d[0].variable_clean + "-legend");
          })
          .on('click', function(){
            var selected = d3.select(this)

            // if the opacity of the selected legend == 1, then make the legend and its line to opacity = 0.2
            if (selected[0][0].style.opacity == 1){
                var e = document.getElementById(selected[0][0].id)  // selected legend
                d3.select(e)
                  .transition()
                  .duration(200)
                  .style("opacity", 0.15)
                // switch to the line from the legend with the same id
                var f = document.getElementById(selected[0][0].id.replace("-legend","-line"))
                d3.select(f)
                  .transition()
                  .duration(200)
                  .style("opacity", 0.15)
                }
                // bring the opacity back if click the legend again
                if (selected[0][0].style.opacity == 0.15){
                var e = document.getElementById(selected[0][0].id)  // selected legend
                d3.select(e)
                  .transition()
                  .duration(200)
                  .style("opacity", 1)
                // switch to the line from the legend with the same id
                var f = document.getElementById(selected[0][0].id.replace("-legend","-line"))
                d3.select(f)
                  .transition()
                  .duration(200)
                  .style("opacity", 1)
                }
            })
            .on("mouseover",function(d){
                d3.select(this)
                  .style("font-size", '18px');
                // also highlight the corresponding legend of the selected line based on id
                var f = document.getElementById(d3.select(this)[0][0].id.replace("-legend","-line"))
                d3.select(f)
                  .style("stroke-width",'4px')          
                 })
            .on("mouseleave",function(d){
                d3.select(this)
                  .style("font-size", '12px');
                // also highlight the corresponding legend of the selected line based on id
                var f = document.getElementById(d3.select(this)[0][0].id.replace("-legend","-line"))
                d3.select(f)
                  .style("stroke-width",'2px')
                });
   
    // add a circle to each element in the legend
    legend.append('circle')
          .attr('cx', w - margin.right + legendMargin)
          .attr("cy", function(d, i) {
              return margin.top * 1.5 + i * height;
          })
          .attr("r",legendCircleSize)
          .style('fill', function(d, i){
                return colours(i)
          });
          
    // add a text to each element in the legend          
    legend.append('text')
          .attr('x', w - margin.right + legendMargin * 1.5)
          .attr('y', function(d, i) {
              return margin.top * 1.5 + i * height;
          })
          .text(function(d,i) { return d[0].variable_clean; })
          .style("stroke",function(d, i){
                return colours(i)
          });  
          
    
        
    // 5.8 axis 
    // setup axis  
    var xAxis = d3.svg.axis()
                      .scale(xscale)
                      .orient("bottom") // control whether the label of axis is above or under the axis line
                      .ticks(10);
    var yAxis = d3.svg.axis()
                      .scale(yscale)
                      .orient("right")
                      .ticks(10);

    // draw x-axis by calling
    canvas.append("g")  // name the axis the g group
          .attr("class","axis") // this echos with the class in css of the html file
          .attr("transform","translate(0," + (h - margin.bottom) + ")")  // transform the entire axis group and push it to the bottom. translate(x,y)
          .call(xAxis);
    // draw y-axis by calling
    canvas.append("g")
          .attr("class","axis")
          .attr("transform","translate(" + (w - margin.right) + ",0)")  // translate(x,y). x: x-corrdinate, y: y-coordinate
          .call(yAxis);

    // add axis titles
    canvas.append("text") // has to be text
          .attr("transform","translate(" + (w - margin.right)/2 + "," + (h - margin.bottom + 40) + ")")
          .style("text-anchor","middle")
          .text("Time interval")
          .style("font-size",'15px')
          //.style("font-weight",700)
          ;
    /*canvas.append("text")
          .attr("transform","translate(" + (w - margin.right + 20) + "," + h/2 + ") rotate(-270)")
          .style("text-anchor","middle")
          .attr("font-size","20px")
          .text("Rank");*/    
        
    
    // end of the redraw function    
    }
    

 // end of d3.json
 });

// end of document ready
});

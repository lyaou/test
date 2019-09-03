
var bookDataFromLocalStorage = [];

$(function(){
    loadBookData();
    var data = [
        //不要用 image/database.jpg
        {text:"資料庫",value:"image/database.jpg"},
        {text:"網際網路",value:"image/internet.jpg"},
        {text:"應用系統整合",value:"image/system.jpg"},
        {text:"家庭保健",value:"image/home.jpg"},
        {text:"語言",value:"image/language.jpg"}
    ]
    $("#book_category").kendoDropDownList({
        dataTextField: "text",
        dataValueField: "value",
        dataSource: data,
        index: 0,
        change: onChange
    });
    $("#bought_datepicker").kendoDatePicker({
        format: "yyyy-MM-dd",
        value: new Date()
    });
    $("#book_grid").kendoGrid({
        dataSource: {
            data: bookDataFromLocalStorage,
            schema: {
                model: {
                    fields: {
                        BookId: {type:"int"},
                        BookName: { type: "string" },
                        BookCategory: { type: "string" },
                        BookAuthor: { type: "string" },
                        BookBoughtDate: { type: "string" },
                        BookPublisher: { type: "string" }
                    }
                }
            },
            pageSize: 20, 
            //對data做排序
            sort: { field: "BookId", dir: "asc"}        
        },
        toolbar: kendo.template("<div class='book-grid-toolbar'><input class='book-grid-search' placeholder='我想要找......' type='text'></input></div>"),
        height: 550,
        sortable: true,
        pageable: {
            input: true,
            numeric: false
        },
        columns: [
            { field: "BookId", title: "書籍編號",width:"10%"},
            { field: "BookName", title: "書籍名稱", width: "50%" },
            { field: "BookCategory", title: "書籍種類", width: "10%" },
            { field: "BookAuthor", title: "作者", width: "15%" },
            { field: "BookBoughtDate", title: "購買日期", width: "15%" },
            { field: "BookPublisher", title: "出版社", width: "15%" },
            { command: { text: "刪除", click: deleteBook }, title: " ", width: "120px" }
        ]
      
    });

    //搜尋功能
    $(".book-grid-search").on("input",function(){
        var value = $(".book-grid-search").val(); 
        
        $("#book_grid").data("kendoGrid").dataSource.filter({
            filters: [{ field: "BookName", operator: "contains", value: value }]  
        });
    });

    //新增的跳出視窗
    $(".fieldlist").kendoWindow({
        width: "35%",       
        modal: true,
        iframe: true,
        resizable: true,
        visible: false,
        actions: [
            "Pin",
            "Minimize",
            "Maximize",
            "Close"
        ],
        close: onClose
      })
    
    //"新增書籍"被按時 跳出新增視窗
    $(".add-book").click(function(){
        $(".fieldlist").data("kendoWindow").center().open();
    });

    //Validator
    var validator = $(".fieldlist").kendoValidator({
        rules: {
            datepicker: function(input){
              if (input.is("[data-role=datepicker]")){
                return input.data("kendoDatePicker").value();
              } 
              else{
                return true;
              }
            }
          },
        messages: {
            datepicker: "Please enter date!"
        }
    }).data("kendoValidator");
    

    //視窗中的"新增"被按時 將資料存入local storage
    $(".btn-add-book").click(function(){
        if(validator.validate())
        {   
            var index = (bookDataFromLocalStorage.length-1);
            var inputData = {
                //最大BookId +1
                "BookId": (bookDataFromLocalStorage[index].BookId + 1),
                "BookCategory": $(".k-input").text(),
                "BookName": $("#book_name").val(),
                "BookAuthor": $("#book_author").val(),
                "BookBoughtDate": $("#bought_datepicker").val(),
                "BookPublisher": $("#book_publisher").val()
            }
        
            
            //把資料輸入bookDataFromLocalStorage
            bookDataFromLocalStorage.push(inputData);
            //console.log(bookDataFromLocalStorage);
            //將資料重新指定回localStorage
            localStorage.setItem("bookData",JSON.stringify(bookDataFromLocalStorage));
            $("#book_grid").data("kendoGrid").dataSource.data(bookDataFromLocalStorage);
            $(".fieldlist").data("kendoWindow").close();

            $("#book_name").val("");
            $("#book_author").val("") ;
            $("#book_publisher").val("");
        }
        
    });


})


function loadBookData(){
    bookDataFromLocalStorage = JSON.parse(localStorage.getItem("bookData"));
    if(bookDataFromLocalStorage == null){
        bookDataFromLocalStorage = bookData;
        localStorage.setItem("bookData",JSON.stringify(bookDataFromLocalStorage));
    }
}

//改變圖片 
function onChange(){
    $(".book-image").attr("src",this.value())
}

//刪除資料
function deleteBook(e){
    e.preventDefault();
    var dataItem = $(e.target).closest("tr"); //row
    var data = this.dataItem(dataItem);
    
    $("#book_grid").data("kendoGrid").dataSource.remove(data);

    for(var i=0; i < bookDataFromLocalStorage.length; i++)
    {
        if(data.BookId == bookDataFromLocalStorage[i].BookId)
            bookDataFromLocalStorage.splice(i,1);
    };
    
    localStorage.setItem("bookData",JSON.stringify(bookDataFromLocalStorage));
}

//關閉視窗
function onClose(){
    $(".add-book").fadeIn();
}
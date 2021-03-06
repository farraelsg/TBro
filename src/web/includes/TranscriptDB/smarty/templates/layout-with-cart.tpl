{#extends file='layout.tpl'#}
{#block name='head'#}
    <script type="text/javascript">
        //will be used by cart-init.js
        var cartoptions = {
            serviceNodes: {
                itemDetails: '{#$ServicePath#}/details/features',
                sync: '{#$ServicePath#}/cart/sync'
            }
        };
        var cartlimits = {
            max_carts_per_context: {#$max_carts_per_context#},
            max_items_per_cart: {#$max_items_per_cart#},
            max_annotations_per_context: {#$max_annotations_per_context#}
        };
        var appPath = '{#$AppPath#}';
        /*
         function openPasteDialog(event){
         event.preventDefault();
         $('#dialog-paste-cart-group').dialog('open');
         }
         function openCopyAllContextDialog(event){
         event.preventDefault();
         var dialog = $('#dialog-copy-all-carts');
         dialog.data('data', cart.exportAllGroupsOfCurrentContext());
         dialog.dialog('open');
         }
         function openCopyAllDialog(event){
         event.preventDefault();
         var dialog = $('#dialog-copy-all-carts');
         dialog.data('data', cart.exportAllGroups());
         dialog.dialog('open');
         }
         function openDeleteAllContextDialog(event){
         event.preventDefault();
         $('#dialog-delete-all-context').dialog('open');
         }
         function openDeleteAllDialog(event){
         event.preventDefault();
         $('#dialog-delete-all').dialog('open');
         }
         function openDeleteAnnotationsContextDialog(event){
         event.preventDefault();
         $('#dialog-delete-annotations-context').dialog('open');
         }
         function openDeleteAnnotationsDialog(event){
         event.preventDefault();
         $('#dialog-delete-annotations').dialog('open');
         }
         */
    </script>
    <script type="text/javascript" src="{#$AppPath#}/js/cart.js"></script>
    <script type="text/javascript" src="{#$AppPath#}/js/cart-init.js"></script>


    <style>
        .ui-accordion .ui-accordion-header {
            margin-bottom:0px;
        }
        .ui-accordion .ui-accordion-content {
            padding: 0.5em 1em;
        }
        .beingDragged {
            list-style: none;
        }
        .beingDragged img {
            display: none;
        }

        fieldset *:last-child{
            margin-bottom: 0px;
        }

        form {
            margin: 0px;
        }
        .cartMenuContent{
            display:none;
            width: auto;
            white-space: nowrap;
        }
        .cartMenuButton{
            margin-bottom: 0px;
        }
        .cartgroup{
            background-color: white;
            background: white;
        }
        .cartgroup:hover{
            background-color: #d9d9d9;
            cursor:pointer;
        }
        .cartMasterDropdown{
            width: auto;
        }
        .cartMenuContent.f-dropdown:after{left:80px !important;} 
        .cartMenuContent.f-dropdown:before{left:81px !important;}
        .warningDialogClass .ui-widget-header {
            color: red;
        }
    </style>
    {#$smarty.block.child#}
{#/block#}
{#block name='body'#}
    <div class="row">
        <div class="large-9 columns">
            {#$smarty.block.child#}
        </div>
        <div class="large-3 columns" >
            <div class="row large-3 columns" style="position:fixed;top:45px;bottom:0;overflow-x:hidden;overflow-y:auto;">
                <div style="display: none">

                    <div id="dialog-rename-cart-group" title="Rename Cart">
                        <form>
                            <fieldset>
                                <label for="cartname">cart name</label>
                                <input type="text" name="name" id="cartname" class="text ui-widget-content ui-corner-all" maxlength="{#$max_chars_cartname#}"/>
                            </fieldset>
                        </form>
                    </div>

                    <div id="dialog-import-finished" title="Import finished">
                        <p>Congratulations, you have successfully imported your carts.</p>
                    </div>

                    <div id="dialog-delete-all-context" title="Delete all Carts (Release)?">
                        <p><span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 20px 0;"></span>This will remove all your carts in the current release. Are you sure?</p>
                    </div>

                    <div id="dialog-delete-all" title="Delete all Carts (all Releases)?">
                        <p><span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 20px 0;"></span>This will remove all your carts from all releases. Are you sure?</p>
                    </div>

                    <div id="dialog-delete-annotations-context" title="Delete all Carts (Release)?">
                        <p><span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 20px 0;"></span>This will remove all your carts in the current release. Are you sure?</p>
                    </div>

                    <div id="dialog-delete-annotations" title="Delete all Carts (all Releases)?">
                        <p><span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 20px 0;"></span>This will remove all your carts from all releases. Are you sure?</p>
                    </div>

                    <div id="dialog-delete-cart" title="Delete this cart?">
                        <p>
                            <span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 20px 0;"></span>
                            This action can not be undone. Are you sure?
                        </p>
                    </div>

                    <div id="dialog-delete-item" title="Delete this item?">
                        <p>
                            <span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 20px 0;"></span>
                            This action can not be undone. Are you sure?
                        </p>
                    </div>

                    <div id="dialog-delete-item-annotation" title="Delete annotation?">
                        <p>
                            <span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 20px 0;"></span>
                            This action can not be undone. Are you sure?
                        </p>
                    </div>

                    <div id="dialog-edit-cart-item" title="Edit Item">
                        <form>
                            <fieldset>
                                <label for="item-name">Name</label>
                                <input type="text" name="name" id="item-name" class="text ui-widget-content ui-corner-all" readonly/>
                                <label for="item-db-description">DB Description</label>
                                <input type="text" name="db-description" id="item-db-description" class="text ui-widget-content ui-corner-all" readonly/>
                                <label for="item-alias">User Alias</label>
                                <input type="text" name="alias" id="item-alias" class="text ui-widget-content ui-corner-all" maxlength="{#$max_chars_user_alias#}"/>
                                <label for="item-annotations">User Description</label>
                                <textarea name="annotations" id="item-annotations" class="text ui-widget-content ui-corner-all" maxlength="{#$max_chars_user_description#}"></textarea>
                                <div class="right"><small>Max. {#$max_chars_user_description#} characters</small></div>
                            </fieldset>
                        </form>
                    </div>

                    <div id="dialog-edit-cart-notes" title="Edit Cart Notes">
                        <form>
                            <fieldset>
                                <label for="item-name">Cart</label>
                                <input type="text" name="name" id="cart-name" class="text ui-widget-content ui-corner-all" readonly/>
                                <label for="item-annotations">User Description</label>
                                <textarea name="annotations" id="cart-notes" class="text ui-widget-content ui-corner-all" maxlength="{#$max_chars_cartnotes#}"></textarea>
                                <div class="right"><small>Max. {#$max_chars_cartnotes#} characters</small></div>
                            </fieldset>
                        </form>
                    </div>

                    <div id="dialog-paste-cart-group" title="Import Group">
                        <form>
                            <fieldset>
                                <label for="paste-json">Data as created using the "Export Group" feature:</label>
                                <textarea id="paste-json" class="text ui-widget-content ui-corner-all" style="height: 350px"></textarea>
                                <label for="metadata-conflict">How to treat annotations?</label>
                                <select id="metadata-conflict">
                                    <option value="merge">prefer existing (if conflicting)</option>
                                    <option value="keep">keep existing (do not import any)</option>
                                    <option value="overwrite">prefer imported (if conflicting)</option>
                                </select>
                                <label for="group-conflict">What to do with conflicting carts?</label>
                                <select id="group-conflict">
                                    <option value="keep">keep existing</option>
                                    <option value="merge">merge items</option>
                                    <option value="copy">create a new cart from the imported (same name but with suffix _1)</option>
                                    <option value="overwrite">overwrite with imported</option>
                                </select>
                            </fieldset>
                        </form>
                    </div>

                    <div id="dialog-copy-cart-group" title="Export Group">
                        <form>
                            <fieldset>
                                <label for="copy-json">You can copy the data below. It may be re-imported by anyone using the "Import" feature.</label>
                                <textarea id="copy-json" class="text ui-widget-content ui-corner-all" style="height: 375px"></textarea>
                            </fieldset>
                        </form>
                    </div>

                    <div id="dialog-copy-all-carts" title="Export All Carts">
                        <form>
                            <fieldset>
                                <label for="copy-all-json">You can copy the data below. It may be re-imported by anyone using the "Import" feature.</label>
                                <textarea id="copy-all-json" class="text ui-widget-content ui-corner-all" style="height: 375px"></textarea>
                            </fieldset>
                        </form>
                    </div>
                </div>

                <div class="panel large-12 columns" style="text-align: center">
                    {#if (isset($smarty.session['OpenID'])) #}
                        <form action="?logout" method="post">
                            <button class="button large">Logout</button>
                        </form>
                    {#else#}
                        <form action="?login" method="post">
                            <button class="button large">Login with StackExchange</button>
                        </form>
                    {#/if#}
                </div>

                <div class="panel large-12 columns" id="cart">
                    <div>
                        <h4 class="left">Carts</h4>
                        <div class="right">
                            <button class="button dropdown" id="" data-dropdown="cart-dropdown-master">Manage</button>
                            <ul class="f-dropdown cartMasterDropdown" id="cart-dropdown-master" data-dropdown-content>
                                <li onclick="cart.addGroup();">New</li>
                                <li onclick="$('#dialog-paste-cart-group').dialog('open');">Import</li>
                                <li onclick="var dialog = $('#dialog-copy-all-carts');
            dialog.data('data', cart.exportAllGroupsOfCurrentContext());
            dialog.dialog('open');">Export (Release)</li>
                                <li onclick="var dialog = $('#dialog-copy-all-carts');
            dialog.data('data', cart.exportAllGroups());
            dialog.dialog('open');">Export (All)</li>
                                <li onclick="$('#dialog-delete-all-context').dialog('open');">Delete (Release)</li>
                                <li onclick="$('#dialog-delete-all').dialog('open');">Delete (All)</li>
                                <li onclick="$('#dialog-delete-annotations-context').dialog('open');">Delete Annotations (Release)</li>
                                <li onclick="$('#dialog-delete-annotations').dialog('open');">Delete Annotations (All)</li>
                            </ul>
                        </div>
                        <div style="clear:both">&nbsp;</div>
                    </div>
                    <div id="Cart">

                    </div>
                </div>
            </div>

            <script type="text/template" id="template_cart_new_group"> 
                <div class="sortable" data-name="<%= groupname %>">
                &nbsp;
                <div class='cartGroup' id="cartgroup-<%= groupname %>" data-name="<%= groupname %>" title="<%= groupname %>">
                <div class="large-12 columns cartgroup handle">
                <div class="left" style="position:absolute; top:50%; margin-top:-10px;"><%= groupname %>
                <span class="numelements">(0)</span></div>
                <div class="right">
                <button class="cartMenuButton small button dropdown" data-cartMenu="cart-dropdown-group-<%= groupname %>">Actions</button>
                <ul id="cart-dropdown-group-<%= groupname %>"  class="f-dropdown cartMenuContent">
                <li><a class="cart-button-rename" href="#"><img alt="Rename Group" src="{#$AppPath#}/img/mimiGlyphs/39.png"/>&nbsp;Rename</a></li>
                <li><a class="cart-button-copy" href="#"><img alt="Export Group"  src="{#$AppPath#}/img/mimiGlyphs/9.png"/>&nbsp;Export</a></li>
                <li><a class="cart-button-remove" href="#"><img alt="Remove Group" src="{#$AppPath#}/img/mimiGlyphs/51.png"/>&nbsp;Delete</a></li>
                <li><a href="{#$AppPath#}/graphs/<%= groupname %>"><img alt="Execute Group Actions" src="{#$AppPath#}/img/mimiGlyphs/7.png"/>&nbsp;View&nbsp;/&nbsp;Modify</a></li>
                <li><a href="{#$AppPath#}/graphs/<%= groupname %>#tabs-graphs"><img alt="Execute Group Actions" src="{#$AppPath#}/img/mimiGlyphs/23.png"/><b>&nbsp;Analyse</b></a></li>
                </ul>
                </div>
                </div>
                <ul class="large-12 columns elements">
                <li class="placeholder">
                drag your items here
                </li>
                </ul>
                </div>
                </div>
            </script>

            <script type="text/template"  id="template_cart_new_item"> 
                <li style="clear:both" class="large-12 cartItem" data-id="<%=item.feature_id%>">
                <div class="left">
                <span class="displayname">
                <% if(typeof item.metadata !== 'undefined' && item.metadata.alias){print('<b>');} %>
                <%= (item.metadata && item.metadata.alias) || item.alias || item.name || item.feature_id %>
                <% if(typeof item.metadata !== 'undefined' && item.metadata.alias){print('<b>');} %>
                </span>
                </div>
                <div class="right">
                <a href="{#$AppPath#}/details/byId/<%= item.feature_id %>"><img src="{#$AppPath#}/img/mimiGlyphs/47.png"/> </a> 
                <a class="cart-button-rename" href="#"><img class="cart-button-edit" src="{#$AppPath#}/img/mimiGlyphs/39.png"/> </a>
                <a class="cart-button-delete" href="#"><img src="{#$AppPath#}/img/mimiGlyphs/51.png"/></a>
                </div>
                </li>
            </script>
        </div>
        <div>&nbsp;</div>
    </div>

    <div id="TooManyCartsDialog" class="reveal-modal medium" data-reveal>
        <h2>Unable to create new cart.</h2>
        <p>You have already reached the limit of {#$max_carts_per_context#} carts for this context.</p>
        <a class="close-reveal-modal">&#215;</a>
    </div>
    <div id="TooManyItemsDialog" class="reveal-modal medium" data-reveal>
        <h2>Unable to add item to cart.</h2>
        <p>You have already reached the limit of {#$max_items_per_cart#} items for this cart.</p>
        <a class="close-reveal-modal">&#215;</a>
    </div>
    <div id="TooManyAnnotationsDialog" class="reveal-modal medium" data-reveal>
        <h2>Unable to create new annotation.</h2>
        <p>You have already reached the limit of {#$max_annotations_per_context#} annotations for this context.</p>
        <a class="close-reveal-modal">&#215;</a>
    </div>
</div>
{#/block#}
{#extends file='layout.tpl'#}
{#block name='head'#}
{#call_webservice path="details/isoform" data=["query1"=>$isoform_uniquename] assign='data'#}

<!--[if lt IE 9]><script type="text/javascript" src="http://canvasxpress.org/js/flashcanvas.js"></script><![endif]-->
<script type="text/javascript" src="http://canvasxpress.org/js/canvasXpress.min.js"></script>
<!-- use chrome frame if installed and user is using IE -->
<meta http-equiv="X-UA-Compatible" content="chrome=1">
<script type="text/javascript">
    var isoform = '{#$data.isoform.uniquename#}';

    $(document).ready(function() {
        $.ajax('{#$ServicePath#}/graphs/genome/isoform/' + isoform, {
            success: function(val) {
                new CanvasXpress(
                        "canvas-{#$data.isoform.uniquename#}",
                        {
                            "tracks": val.tracks
                        },
                {
                    graphType: 'Genome',
                    useFlashIE: true,
                    backgroundType: 'gradient',
                    backgroundGradient1Color: 'rgb(0,183,217)',
                    backgroundGradient2Color: 'rgb(4,112,174)',
                    oddColor: 'rgb(220,220,220)',
                    evenColor: 'rgb(250,250,250)',
                    missingDataColor: 'rgb(220,220,220)',
                    setMin: val.min,
                    setMax: val.max
                }
                );
            }
        });
        $('form.blast').submit(function(event) {
            queryInput = $(this).find('.query');
            query = $(queryInput.data('ref')).html();
            queryInput.val(query);
        });
    });



</script>
{#/block#}

{#block name='body'#}
<div class="row">
    <div class="large-12 columns panel">
        <ul class="inline-list">
            <li>Quick Navigation:</li>
            <li><a href="#description">Isoform Description</a></li>
            {#if isset($data.isoform.repeatmasker) && count($data.isoform.repeatmasker) > 0 #}
            <li><a href="#repeatmasker">Repeatmasker Annotations</a></li>
            {#/if#}
            {#if isset($data.isoform.predpeps) && count($data.isoform.predpeps) > 0 #}
            <li><a href="#predpep">Predicted Peptides</a></li>
            {#/if#}
            </dl>
    </div>
</div>
<div class="row">
    <div class="large-12 columns panel" id="description">
        <h1>{#$data.isoform.uniquename#}</h1>
        <h5>last modified: {#$data.isoform.timelastmodified#}</h5>
        <h5>corresponding unigene: <a href="{#$AppPath#}/unigene-details/{#$data.isoform.unigene.uniquename#}">{#$data.isoform.unigene.uniquename#}</a></h5>
    </div>
</div>
<div class="row">        
    <div class="large-12 columns panel">
        <canvas id="canvas-{#$data.isoform.uniquename#}" width="910"></canvas>
        <div style="clear:both; height:1px; overflow:hidden">&nbsp;</div>
    </div>
</div>
<div class="row">
    <div class="large-12 columns panel">

        <div class="row">
            <div class="large-6 columns">
                <h2>Sequence</h2>
            </div>
            <div class="large-6 columns" style="text-align: right">
                <form class="blast" action="http://blast.ncbi.nlm.nih.gov/Blast.cgi" type="POST" target="_blank" style="display:inline">
                    <input type="hidden" name='CMD' value='Web' />
                    <input type="hidden" name='PROGRAM' value='blastx' />
                    <input type="hidden" name='BLAST_PROGRAMS' value='blastx' />
                    <input type="hidden" name='PAGE_TYPE' value='BlastSearch' />
                    <input type="hidden" name='SHOW_DEFAULTS' value='on' />
                    <input type="hidden" name='LINK' value='blasthome' />
                    <input type="hidden" class="query" data-ref="#sequence-{#$data.isoform.uniquename|clean_id#}" name="QUERY" value="" />
                    <input type="submit" class="small button" value="send to blastx">
                </form>

                <form class="blast" action="http://blast.ncbi.nlm.nih.gov/Blast.cgi" type="POST" target="_blank" style="display:inline">
                    <input type="hidden" name='CMD' value='Web' />
                    <input type="hidden" name='PROGRAM' value='blastn' />
                    <input type="hidden" name='BLAST_PROGRAMS' value='megaBlast' />
                    <input type="hidden" name='PAGE_TYPE' value='BlastSearch' />
                    <input type="hidden" name='SHOW_DEFAULTS' value='on' />
                    <input type="hidden" name='LINK' value='blasthome' />
                    <input type="hidden" class="query" data-ref="#sequence-{#$data.isoform.uniquename|clean_id#}" name="QUERY" value="" />
                    <input type="submit" class="small button" value="send to blastn">
                </form>
            </div>
        </div>
        <div class="row">
            <div class="large-12 columns">
                <textarea style="height:100px;" id="sequence-{#$data.isoform.uniquename|clean_id#}">{#$data.isoform.residues#}</textarea>
            </div>
        </div>
    </div>
</div>

<div class="row large-12 columns"><a href="#top" class="button secondary right">back to top</a></div>

{#if isset($data.isoform.repeatmasker) && count($data.isoform.repeatmasker) > 0 #}
<div class="row" id="repeatmasker">
    <div class="large-12 columns">
        <h2>Repeatmasker Annotations:</h2>

        {#foreach $data.isoform.repeatmasker as $repeatmasker#}
        <div class="row panel">
            <div class="large-12 columns">
                <table style="width:100%">
                    <tr><td>name</td><td>{#$repeatmasker.repeat_name#}</td></tr>
                    <tr><td>class</td><td>{#$repeatmasker.repeat_class#}</td></tr>
                    {#if $repeatmasker.repeat_family != "" #}
                    <tr><td>family</td><td>{#$repeatmasker.repeat_family#}</td></tr>
                    {#/if#}
                    <tr><td>min</td><td>{#$repeatmasker.fmin#}</td></tr>
                    <tr><td>max</td><td>{#$repeatmasker.fmax#}</td></tr>
                    <tr><td>strand</td><td>{#if $repeatmasker.strand gt 0#}right{#else#}left{#/if#}</td></tr>
                    <tr><td>length</td><td>{#$repeatmasker.fmax-$repeatmasker.fmin+1#}</td></tr>
                </table>
            </div>
        </div>
        <div class="row">&nbsp;</div>
        {#/foreach#}
    </div>

</div>
<div class="row large-12 columns"><a href="#top" class="button secondary right">back to top</a></div>
{#/if#}


{#if isset($data.isoform.predpeps) && count($data.isoform.predpeps) > 0 #}
<div class="anchor"  id="predpep" style="height:40px">&nbsp;</div>
<div class="row">
    <div class="large-12 columns">
        <h2>Predicted Peptides:</h2>

        {#foreach $data.isoform.predpeps as $predpep#}
        <div class="row panel">
            <div class="large-12 columns">

                <div class="row">
                    <div class="large-9 columns">
                        <table style="width:100%">
                            <tr><td>uniquename</td><td>{#$predpep.uniquename#}</td></tr>
                            <tr><td>min</td><td>{#$predpep.fmin#}</td></tr>
                            <tr><td>max</td><td>{#$predpep.fmax#}</td></tr>
                            <tr><td>strand</td><td>{#if $predpep.strand gt 0#}right{#else#}left{#/if#}</td></tr>
                            <tr><td>length</td><td>{#$predpep.seqlen#}</td></tr>
                        </table>
                    </div>
                    <div class="large-3 columns" style="text-align: right">
                        <form class="blast" action="http://blast.ncbi.nlm.nih.gov/Blast.cgi" type="POST" target="_blank">
                            <input type="hidden" name='CMD' value='Web' />
                            <input type="hidden" name='PROGRAM' value='blastp' />
                            <input type="hidden" name='BLAST_PROGRAMS' value='blastp' />
                            <input type="hidden" name='PAGE_TYPE' value='BlastSearch' />
                            <input type="hidden" name='SHOW_DEFAULTS' value='on' />
                            <input type="hidden" name='LINK' value='blasthome' />
                            <input type="hidden" class="query" data-ref="#sequence-{#$predpep.uniquename|clean_id#}" name="QUERY" value="" />
                            <input type="submit" class="small button"  value="send to blastp">
                        </form>
                        <form class="blast" action="http://blast.ncbi.nlm.nih.gov/Blast.cgi" type="POST" target="_blank">
                            <input type="hidden" name='CMD' value='Web' />
                            <input type="hidden" name='PROGRAM' value='tblastn' />
                            <input type="hidden" name='BLAST_PROGRAMS' value='tblastn' />
                            <input type="hidden" name='PAGE_TYPE' value='BlastSearch' />
                            <input type="hidden" name='SHOW_DEFAULTS' value='on' />
                            <input type="hidden" name='LINK' value='blasthome' />
                            <input type="hidden" class="query" data-ref="#sequence-{#$predpep.uniquename|clean_id#}" name="QUERY" value="" />
                            <input type="submit" class="small button"  value="send to tblastn">
                        </form>
                    </div>
                </div>
                <div class="row">
                    <div class="large-12">
                        <textarea style="height:100px;" id="sequence-{#$predpep.uniquename|clean_id#}">{#$predpep.residues#}</textarea>
                    </div>
                </div>

                {#if isset($predpep.interpro) && count($predpep.interpro) > 0 #}
                <div class="row" id="repeatmasker">
                    <div class="large-12 columns">
                        <h4>Interpro Annotations:</h4>

                        <table>
                            <thead>
                            <tr><td>name</td><td>fmin</td><td>fmax</td></tr>
                            </thead>
                            <tbody>
                                {#foreach $predpep.interpro as $interpro#}
                                <tr><td>{#$interpro.uniquename#}</td><td>{#$interpro.fmin#}</td><td>{#$interpro.fmax#}</td></tr>
                                {#/foreach#}
                            </tbody>
                        </table>
                    </div>

                </div>
                <div class="row large-12 columns"><a href="#top" class="button secondary right">back to top</a></div>
                {#/if#}

            </div>
        </div>
        <div class="row">&nbsp;</div>
        {#/foreach#}
    </div>
</div>
<div class="row large-12 columns"><a href="#top" class="button secondary right">back to top</a></div>
{#/if#}
<pre>
{#$data|var_dump#}
</pre>
{#/block#}
#!/user/bin/perl
use strict;

use File::Basename;
use FindBin qw($Bin);
use Encode;
use Win32::OLE;
use Win32::OLE::Variant;

my $shell  = Win32::OLE->new("shell.Application");
my $message= "ѡ��Sims Excel�ļ�����Ŀ¼";
my $folder = $shell->BrowseForFolder( 0, $message, 0 );
my $path   = $folder->Self->Path;
$path =~ s/\\/\//g;

my %front;
my %logo;
my %pdcd;
my @hos;

open PD,"$path/data/Product_Coding.txt" or die $!;
while (<PD>)
{
	chomp; next if /^#/;
	my @line=split(/\t/,$_);
	my ($pdid, $pdna, $pdhos, $pdfront, $pdy) = @line[0, 1, 2, 3, 4];
	my $id_hos = "$pdid$pdhos";
	push @{$pdcd{$id_hos}}, ($pdna, $pdfront, $pdy);
	push @hos, $line[2];

}
close PD;	

my $excel = Win32::OLE->new('Excel.Application') or die $!;
#$excel->{Visible} = 1;  # �Ƿ���ExcelԤ��
#$excel->{DisplayAlerts} = 3;
#open OT,">$path/t.txt" or die $!;


my %res;
for my $xls_result(glob "'$path/2019ncov_result.xls'")
 {
	my $workbook   = $excel->Workbooks->Open($xls_result);
	my $worksheet  = $workbook->Worksheets("result"); 
	my $maxrow = $worksheet->{UsedRange}->{Rows}->{Count};
	my $maxcol = $worksheet->{UsedRange}->{Columns}->{Count};
	for my $row(1..$maxrow)
	{
		my @Res;
		for my $col(1..$maxcol)
		{
			my $t=$worksheet->Cells($row,$col)->{Value}||"-";
			push @Res,$t;
			# print $t,"\n";
		}
		$res{$Res[0]}=$Res[1];
	}
	$workbook->Close();
	$excel->Close();
}
 for  my $key(keys %pdcd)
 {	my $info = $pdcd{$key};
	print "$key => @$info\n";
 }


for my $xls(glob "'$path/������Ϣ.xls*'")
{
	my $book   = $excel->Workbooks->Open($xls);
	my $sheet  = $book->Worksheets("����ά����Ϣ"); 
	unless($sheet) { print STDERR "$xls ��������Ʒ��Ϣ��񣬲�������"; next; }
	my $maxrow = $sheet->{UsedRange}->{Rows}->{Count};
	my $maxcol = $sheet->{UsedRange}->{Columns}->{Count};
	for my $row(1..$maxrow)
	{
		my @tmp;
		for my $col(1..$maxcol)
		{
			my $t=$sheet->Cells($row,$col)->{Value}||"-";
			if($t=~/^#/){
				last;
			}
			#push @tmp,$sheet->Cells($row,$col)->{Value};
			push @tmp,$t;
		}
		if(@tmp && $tmp[5] =~ /\d{7}/){
			&get_report(\@tmp);
		}
	}
	$book->Close();
	$excel->Close();
}

#excel->Quit();

sub get_report{
	my ($cinfo)=@_;
=cut
my ($sid,$sptype,$version,$spvolume,
		$name,$sex,$age,
		$manifestation,$origin_id,
		$wbc,$ly,$neu,$crp,$pct,$culture,$identify,$microscopy,
		$diagnosis,$pathogen,$drug,
		$hospital,$department,$doctor,$collect_date,$recept_date,
		$hosnum,$bednum)=@{$cinfo};#4+3+2+8+3+5+2=27
=cut
		my ($sid,$sptype,$version,$spvolume,
		$name,$sex,$age,
		$manifestation,$origin_id,
		$wbc,$ly,$neu,$crp,$pct,$culture,$identify,$microscopy,
		$diagnosis,$pathogen,$drug,
		$hospital,$department,$doctor,$collect_date,$recept_date,
		$hosnum,$bednum)=@{$cinfo}[5,7,27,76,
		10,11,12,
		24,6,
		77,78,79,80..84,
		60,85,86,
		2,30,4,8,9,
		31,32];
	my $hosid = $hospital;
	unless (grep /^$hospital$/, @hos){$hosid = "�����ڲ�";}
	my $id_hos = "$version$hosid";
	my ($front, $log, $pdna) = ($pdcd{$id_hos}[1], $pdcd{$id_hos}[2], $pdcd{$id_hos}[0]);
	print "$id_hos,$front, $log, $pdna\n";
	my ($sec,$min,$hour,$day,$mon,$year,$wday,$yday,$isdst)=localtime(time());
    $mon +=1; 
    $year +=1900;

    my $date=sprintf("%04d-%02d-%02d %02d:%02d",$year,$mon,$day,$hour,$min);
    my $date1=sprintf("%04d%02d%02d",$year,$mon,$day);

	my %num=('DX1757', '63', 'DX1758', '65', 'DX1759', '62', 'DX1760', '64', 'DX1763', '60', 'DX1761', '61', 'DX1762', '66', 'DX1749', '59', 'DX1783', '74', 'DX1784', '75', 'DX1796', '76' , 'SD0221', '73', 'DX1867', '91', 'DX1868', '92');
	#my %num=('DX1757', '63', 'DX1758', '65', 'DX1759', '62', 'DX1760', '64', 'DX1763', '60', 'DX1761', '61', 'DX1762', '66', 'DX1749', '59' );
	open OUT,">$path/${sid}_${version}_��ʽ����_${name}_$date1.tex" or die $!;
	
	my $content_1; my $content_QM; my %content_s; my %content_r;
	$content_1 ="
	\\documentclass[UTF8]{ctexart}
		%-------------------------------------------------------------����-------------------------
		\\usepackage[T1]{fontenc} %����text��ʽ�»���
		\\usepackage{lmodern} %����text��ʽ�»���
		\\usepackage{geometry}
		\\usepackage{multirow}
		\\usepackage{float}%������
		\\usepackage{colortbl}%���ñ���и�
		\\definecolor{lightgray}{RGB}{245,245,245}
		\\usepackage{makecell} %���ñ����
		\\usepackage{booktabs} %����ߴ�ϸ
		\\usepackage{fancyhdr}%����ҳüҳ��ҳ���
		\\usepackage{graphicx} % ͼ�κ��
		\\usepackage{colortbl} %�����ɫ��
		\\usepackage{setspace}%ʹ�ü����
		\\usepackage{CJK,CJKnumb} %��������
		\\usepackage{array}%���̶��п����ݾ���
		%\\usepackage{natbib}
		%\\usepackage[superscript]{cite} % �����ϱ�
		\\usepackage[super,square,comma,sort&compress]{natbib}
		\\usepackage[normalem]{ulem}%����»���
		\\usepackage{lastpage}%�����ҳ��
		\\usepackage{enumerate} %�б�
		\\usepackage{enumitem} %�����б���
		\\setlist[enumerate,1]{label=\\arabic*��,leftmargin=7mm,labelsep=1.5mm,topsep=0mm,itemsep=-0.8mm}
		%���ˮӡ
		\\usepackage{tikz}
		\\usepackage{xcolor}
		\\usepackage{eso-pic}
		%���ˮӡ
		\\usepackage{longtable} %����ҳ
		\\usepackage{overpic} %������ӻ�����Ϣ

		%------------------------------------------------------����-------------------------------
	%ˮӡ
	\\newcommand\\BackgroundPicture{
		 \\put(0,0){
			\\parbox[b][\\paperheight]{\\paperwidth}{
				\\vfill
				      \\centering
					  \\begin{tikzpicture}[remember picture,overlay]
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at (current page.center) {\\textcolor{gray!80!cyan!30}{PMseq}};
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=5cm,yshift=0cm]current page.west) {\\textcolor{gray!80!cyan!30}{PMseq}};
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=-5cm,yshift=0cm]current page.east) {\\textcolor{gray!80!cyan!30}{PMseq}};

					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=0cm,yshift=-7cm]current page.north) {\\textcolor{gray!80!cyan!30}{PMseq}};
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=-5cm,yshift=-7cm]current page.north east) {\\textcolor{gray!80!cyan!30}{PMseq}};
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=5cm,yshift=-7cm]current page.north west) {\\textcolor{gray!80!cyan!30}{PMseq}};

					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=0cm,yshift=7cm]current page.south) {\\textcolor{gray!80!cyan!30}{PMseq}};
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=5cm,yshift=7cm]current page.south west) {\\textcolor{gray!80!cyan!30}{PMseq}};
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=-5cm,yshift=7cm]current page.south east) {\\textcolor{gray!80!cyan!30}{PMseq}};

			\\end{tikzpicture}
			\\vfill
			}
		}
	}
%ˮӡ
		\\definecolor{mygray}{gray}{.9}
		%\\newCJKfontfamily\msyh{΢���ź�}
		%\\setCJKfamilyfont{yh}{Microsoft YaHei}
		\\definecolor{myblue}{RGB}{0,74,143}


		\\newcommand{\\song}{\\CJKfamily{song}}    % ����
		\\newcommand{\\fs}{\\CJKfamily{fs}}             % ������
		\\newcommand{\\kai}{\\CJKfamily{kai}}          % ����
		\\newcommand{\\hei}{\\CJKfamily{hei}}         % ����
		\\newcommand{\\li}{\\CJKfamily{li}}               % ����

		%-----------------------------------------------����-------------------------
		\\geometry{a4paper,centering,scale=0.8}
		\\pagestyle{fancy} %����ҳüҳ��
		%\\graphicspath{{$Bin/}}
		\\graphicspath{{C:/CTEX/Pictures/}}

		%-------------------------------------------------ҳü����ͼƬ-------------
		\\newsavebox{\\headpic}
		\\sbox{\\headpic}{\\includegraphics[height=2cm]{$log.jpg}} %����ҳülogoҳü
		\\fancyhead[L]{\\usebox{\\headpic}}
		\\fancyhead[C]{\\zihao{-5}������$name \\hspace{1cm}  �������ڣ�$collect_date  \\hspace{1cm}  ������ţ�$sid}
		%--------------------------------------------------����---------------------

		%----------------------------------------------����ҳüҳ�Ÿ�ʽ------------
		
		\\rhead{\\zihao{-5} \\uline{\\hspace{14cm}DX-PMP-B$num{${version}} V1.1} \\vspace{0.1ex}   }
		 \\lfoot{\\zihao{-5} �ͷ��绰��400-605-6655  \\hspace{0.8cm} ��ַ:www.bgidx.cn}
		\\cfoot{}%�и����ҳ���м䲻����ҳ��
		%\\rfoot{\\thepage}
		\\rfoot{\\thepage \\ / \\pageref{LastPage}}
		\\renewcommand{\\headrulewidth}{0.2pt}%��Ϊ0pt����ȥ��ҳ������ĺ���   
		\\renewcommand{\\footrulewidth}{0.2pt}
		%-------------------------------------------------����--------------------
		\\setlength{\\extrarowheight}{4mm} %����и�
		%\\setlength{\\parindent}{0pt}%���ײ�����
		%------------------------------------------��ʼ����--------------------------
		\\begin{document}
		\\bibliographystyle{unsrt} % �����������������õ�˳������
		\\AddToShipoutPicture{\\BackgroundPicture} %ˮӡ		
		%-----------------------------------------��ҳ����ͼƬ----------------------
		\\newgeometry{left=-0.8cm,bottom=0cm,right=0.8cm,top=0cm}%���ĵ���ҳ��ҳ�߾� 
		\\setcounter{page}{0} %ҳ��1�ӵڶ�ҳ��ʼ
		\\thispagestyle{empty} %��ҳ����ʾҳüҳ��

		%������ӻ�����Ϣ
		\\begin{overpic}[width=\\textwidth,height=\\textheight,keepaspectratio]{$front.png}
		\\put(15,21){\\begin{tabular}{cp{270 pt}<{\\centering}}%19
		\\textcolor{myblue}{\\zihao{4}\\bfseries \\makebox[3.5em][s]{����}} & \\textcolor{myblue}{\\zihao{4}\\bfseries $name}\\\\
		\\arrayrulecolor{myblue}\\cline{2-2}
		\\textcolor{myblue}{\\zihao{4}\\bfseries �������} & \\textcolor{myblue}{\\zihao{4}\\bfseries $sid}\\\\
		\\cline{2-2}
		\\textcolor{myblue}{\\zihao{4}\\bfseries ��������} & \\textcolor{myblue}{\\zihao{4}\\bfseries $sptype}\\\\
		\\cline{2-2}
		\\textcolor{myblue}{\\zihao{4}\\bfseries �����Ŀ} & \\textcolor{myblue}{\\zihao{4}\\bfseries $pdna}\\\\
		\\cline{2-2}
		\\textcolor{myblue}{\\zihao{4}\\bfseries �ͼ쵥λ} & \\textcolor{myblue}{\\zihao{4}\\bfseries $hospital}\\\\
		
		\\cline{2-2}
		\\end{tabular}}
		\\end{overpic}		
		
		
		\\restoregeometry %�ָ���ԭ����ҳ�߾�
		%------------------------------------------------------����-----------------------------
		%\\clearpage
		\\newpage
		\\topskip 1.5cm
		%\\vspace{6mm}%ҳü���������ļ�Ĵ�ֱ���

		\\noindent %���񣬲�����
		{\\hei\\zihao{4}\\bfseries ������Ϣ} %�������ʹ�þ���ҳü�ľ���������һ����
		%-------------------------------------------------------��ʼ���-----------------------------------------------------
		\\begin{table}[H]
		%\\small% ������ݴ�С
		\\zihao{-4}{\\bfseries
		%\\centering
		%\\begin{tabular}{|lll|}
		\\renewcommand\\arraystretch{0.85} %���ñ���и�
		\\begin{tabular}{|p{0.33\\textwidth}|p{0.33\\textwidth}|p{0.33\\textwidth}|} %���ñ����
		\\hline
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{�ܼ�����Ϣ} \\\\%���ߵ����ã�
		\\hline
		������$name & �Ա�$sex & ���䣺 $age \\\\
		\\hline
		סԺ�ţ�$hosnum & ���ţ�$bednum & ԭ������ţ� $origin_id  \\\\
		\\hline
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{�ٴ���Ϣ} \\\\
		\\hline
		\\multicolumn{3}{|p{\\textwidth}|}{ �ٴ����֣�$manifestation} \\\\
		\\hline
		\\multicolumn{3}{|p{\\textwidth}|}{�ٴ����} \\\\
		\\hline
		\\end{tabular}
		\\begin{tabular}{|p{0.243\\textwidth}|p{0.24\\textwidth}|p{0.24\\textwidth}|p{0.24\\textwidth}|} %���ñ���ȣ�������������
		ѪWBC��$wbc & �Լ�ҺWBC��$ly & �ظ�ˮWBC��$neu & CRP��$crp \\\\
		\\hline
		PCT��$pct & ���������$culture & ���������$identify & ��������$microscopy \\\\
		\\hline
		
		\\multicolumn{4}{|p{\\textwidth}|}{�ٴ���ϣ�$diagnosis} \\\\
		\\hline
		\\multicolumn{4}{|p{\\textwidth}|}{�ص��ע��ԭ��$pathogen} \\\\
		\\hline
		\\multicolumn{4}{|p{\\textwidth}|}{����Ⱦ��ҩ��$drug} \\\\
		\\hline
		\\rowcolor{mygray}\\multicolumn{4}{|c|}{������Ϣ} \\\\
		\\end{tabular}
		\\begin{tabular}{|p{0.33\\textwidth}|p{0.33\\textwidth}|p{0.33\\textwidth}|} %���ñ����
		\\hline
		�ͼ쵥λ��$hospital & �ͼ���ң�$department & �ͼ�ҽʦ��$doctor  \\\\
		\\hline
		�������ڣ�$collect_date & �������ڣ�$recept_date & �������ڣ�$date \\\\
		\\hline
		������ţ�$sid & �������ͣ�$sptype &  ���������$spvolume  \\\\
		%\\Xhline{1pt}
	    \\hline
		\\end{tabular}
		";
$content_s{'DX1749'}="\\begin{tabular}{|p{0.5\\textwidth}<{\\centering}|p{0.515\\textwidth}<{\\centering}|} %���ñ����
		\\rowcolor{mygray}\\multicolumn{2}{|c|}{�����} \\\\
		\\hline
		������ & ����� \\\\
		\\hline
		tcdA & \\\\
		\\hline
		tcdB & \\\\
		\\hline
		\\end{tabular}}
		\\begin{tabular}{|p{1.04\\textwidth}|} %���ñ���ȣ�������������
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} �����˵����}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad�������������������ǲ����ֻ꣬�в������²�����Ҫ��������Ϊ�������������A��tcdA����ϸ������B��tcdB����Ŀǰ���ٴ������õļ���������ݶ��ػ����ͷ�Ϊ3�֣�A-B-��A-B+��A+B+�͡�A-B-�;��겻���ж��������Ϊ�ǲ����ꡣA-B+��A+B+�;��꺬�ж��ػ���ͳ��Ϊ�����ꡣ 
		
		\\qquad�������,tcdA����������/���ԣ�tcdB����������/���ԣ�˵���������м������������ΪA-B-/A-B+/A+B+�����ͣ�����Ϊ�ǲ�����/�����ꡣ\\\\
		\\hline
		\\end{tabular}
		\\end{table}
		\\newpage
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} ˵����}
		\\end{spacing}
		\\begin{enumerate}
		\\item ��������ӫ��PCR���������ڼ���޲��ܱ�֤���Լ����
		
		\\item ���Ͻ��۾�Ϊʵ���Ҽ�����ݣ������ٴ��ο���������Ϊ������Ͻ����
		
		\\item �˱��������Ա����ͼ��������𣬱�����ؽ�������ѯ�ٴ�ҽ����
		\\end{enumerate}
		\\vspace{10ex} % ���ӿ���

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries �������ڣ�$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} ��¼}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} �ο�����}
		\\end{spacing}";
$content_s{'DX1763'}="\\begin{tabular}{|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|} %���ñ����
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{�����} \\\\
		\\hline
		������ & �������� & ����� \\\\
		\\hline
		�������� & Enterovirus & \\\\
		\\hline
		\\end{tabular}}
		\\begin{tabular}{|p{1.04\\textwidth}|} %���ñ���ȣ�������������
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} �²���˵����}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad����ڲ����ɳ�����������Ĵ�Ⱦ�����෢����5�����¶�ͯ���������֡��㡢��ǻ�Ȳ�λ��������������������ļ��ס���ˮ�ס��޾�����Ĥ���׵Ȳ���֢�������鷢չ�죬���������֢������������������ڲ��ĳ���������20���֣��ͣ��������没��A���16��4��5��9��10�ͣ�B���2��5�ͣ��Լ���������71�ͣ���Ϊ����ڲ��ϳ����Ĳ�ԭ�壬�����Կ����没��A16�ͣ�Cox A16���ͳ�������71�ͣ�EV 71����Ϊ����\$^{[1-3]}\$ �� \\\\ 
		\\hline
		\\end{tabular}
		\\end{table}
		\\newpage
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} ˵����}
		\\end{spacing}
		\\begin{enumerate}
		\\item ��������ӫ��PCR���������ڼ���޲��ܱ�֤���Լ����
		
		\\item ���Ͻ��۾�Ϊʵ���Ҽ�����ݣ������ٴ��ο���������Ϊ������Ͻ����
		
		\\item �˱��������Ա����ͼ��������𣬱�����ؽ�������ѯ�ٴ�ҽ����
		\\end{enumerate}
		\\vspace{10ex} % ���ӿ���

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries �������ڣ�$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} ��¼}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} �ο�����}
		\\end{spacing}";
$content_s{'DX1758'}="\\begin{tabular}{|p{0.243\\textwidth}|p{0.24\\textwidth}|p{0.24\\textwidth}|p{0.24\\textwidth}|}
		\\rowcolor{mygray}\\multicolumn{4}{|c|}{�����} \\\\
		\\hline
		��ҩ���� & ��Ӧø & ��ҩ�� & ����� \\\\
		\\hline
		CTX-M1 & ��-������ø & �ɵ��°�Ī���֡��������֡�ͷ��߻����ͷ����뿡��ȷ�ù����ҩ�￹�ԣ��԰�����Ҳ�п��� & \\\\
		\\hline
		\\end{tabular}}
		\\end{table}
		\\newpage
		\\begin{table}[H]
		\\zihao{-4}{\\bfseries
		\\renewcommand\\arraystretch{0.95} %���ñ���и�
		\\begin{tabular}{|p{0.243\\textwidth}|p{0.24\\textwidth}|p{0.24\\textwidth}|p{0.24\\textwidth}|}
		\\hline
		KPC & ̼��ùϩø & �ɵ����ǰ����ϡ��������ϡ��������֡�ͷ�������ơ�ͷ����뿡������ϡ��������֡�ͷ����뿡�ͷ����ड��������ϵȿ��� & \\\\
		\\hline
		IMP & ������-������ø & �ɵ��°������֡��濨���֡�ͷ��������ͷ����ड��ǰ����ϡ��������ϵ�̼��ùϩ�࣬ͷ�߾�����ҩ�￹�� & \\\\
		\\hline
		VIM & ������-������ø & �ɵ���ͷ��������ͷ�������ơ�ͷ��������ͷ����ड��ǰ����ϡ��������ϵ�̼��ùϩ�࣬ͷ�߾�����ҩ�￹�� & \\\\
		\\hline
		NDM & ������-������ø & �ɵ���ͷ����뿡�ͷ����ड�ͷ�������ơ��������ϡ��������ϡ��ǰ����ϵȿ��� & \\\\
		\\hline
		SIM & ������-������ø & �ɵ���ͷ�߾����ࡢ̼��ùϩ��ҩ�￹�� & \\\\
		\\hline
		DIM & ������-������ø & �ɵ���ͷ����������Ī���֡��濨���֡��������֡�ͷ����뿡��ǰ����ϵȿ��� & \\\\
		\\hline
		\\end{tabular}}
		\\begin{tabular}{|p{1.04\\textwidth}|} %���ñ���ȣ�������������
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} �����˵����}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad���Լ������������ⶨ�Լ�⵼��ϸ����ҩ��ص���ø���򣬰��������ͳ����צ�-������ø��CTX-M1�ͱ��������̼��ùϩ����ҩ̼��ùϩø������򣬼����λ�������ϵ�̼��ùϩø�����A�ࣨKPC����B�ࣨIMP,VIM,NDM,SIM,DIM����7����ҩ��ػ���Ϊϸ����ҩ���ߵ������ṩ�����ֶΡ� \\\\
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} ���ۣ�}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad���μ���У�ϸ����ҩ�����Ϊ���ԣ������ҩ����CTX-M1/KPC/ IMP/VIM/NDM/SIM/DIM ���ɵ���ҩ�￹�Լ��������ҩ�ס����μ���У�ϸ����ҩ�����Ϊ���ԣ�δ�������Ʒ��ⷶΧ�ڵ���ҩ���� \\\\
		\\hline
		\\end{tabular}
		\\end{table}
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} ˵����}
		\\end{spacing}
		\\begin{enumerate}
		\\item ��������ӫ��PCR���������ڼ���޲��ܱ�֤���Լ����
		
		\\item ���Ͻ��۾�Ϊʵ���Ҽ�����ݣ������ٴ��ο���������Ϊ������Ͻ����
		
		\\item �˱��������Ա����ͼ��������𣬱�����ؽ�������ѯ�ٴ�ҽ����
		\\end{enumerate}
		\\vspace{10ex} % ���ӿ���

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries �������ڣ�$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} ��¼}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} �ο�����}
		\\end{spacing}";
$content_s{'DX1757'}="\\begin{tabular}{|p{0.33\\textwidth}|p{0.33\\textwidth}|p{0.33\\textwidth}|} 
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{�����} \\\\
		\\hline
		�����Ŀ & ������� & ����� \\\\
		\\hline
		��˷�֦�˾� & ��˷�֦�˾� & \\\\
		\\hline
		\\multirow{4}{*}{����ƽ��ҩ����} & rpoB���򰱻���507-512ͻ�� & \\\\
		\\cline{2-3}
		\~ & rpoB���򰱻���512-520ͻ�� & \\\\
		\\cline{2-3}
		\~ & rpoB���򰱻���520-528ͻ�� & \\\\
		\\cline{2-3}
		\~ & rpoB���򰱻���528-533ͻ�� & \\\\
		\\hline
		\\end{tabular}}
		\\end{table}
		\\newpage
		\\begin{table}[H]
		\\zihao{-4}{\\bfseries
		\\renewcommand\\arraystretch{0.95} %���ñ���и�
		\\begin{tabular}{|p{0.33\\textwidth}|p{0.33\\textwidth}|p{0.33\\textwidth}|} 
		\\hline
		\\multirow{2}{*}{��������ҩ����} & katG(315G>C) & \\\\
		\\cline{2-3}
		\~ & InhA(-15C>T) & \\\\
		\\hline
		\\end{tabular}}
		\\begin{tabular}{|p{1.04\\textwidth}|} %���ñ���ȣ�������������
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} �����˵����}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad{\\noindent\\hei\\bfseries\\zihao{4} ��˷�֦�˾�c��} ��˷�֦�˾���Mycobacterium tuberculosis��MTB�����������˲��Ĳ�ԭ�������ַ�ȫ������٣����Էν��Ϊ����������������Ĥ�׵ȡ�\\\\
		\\setlength{\\baselineskip}{18pt}	\\qquad{\\noindent\\hei\\bfseries\\zihao{4} ����ƽ��ҩ����c��} ��⵼�½�˷�֦�˾�����ƽ��ҩ��rpoB�����һ��81bp�ĺ�����ҩ���ڵĻ���ͻ�䣨�û���ĵ�507λ������\$\\sim\$533λ�����ᣬ����533λ�����������ӵ�ͻ�䲻�ڴ��Լ��еļ�ⷶΧ�ڣ���������ֻҪ��1����������ͻ�䣬˵������ƽ��ҩ�� \\\\
		\\setlength{\\baselineskip}{18pt}	\\qquad{\\noindent\\hei\\bfseries\\zihao{4} ��������ҩ����d��} ��⵼�½�˷�֦�˾���������ҩ��katG����ĵ�315������Ļ���ͻ�䣨K315G>C����InhA��������������Ļ���ͻ�䣨-15 C>T��������katG����Ұ����ΪGG���Ӻ�ͻ����ΪGC������ͻ����ΪCC������InhA����Ұ����ΪCC���Ӻ�ͻ����ΪCT������ͻ����ΪTT��2������ֻҪ��һ��������ͻ�䣨�Ӻ�ͻ��򴿺�ͻ�䣩��˵����������ҩ�� \\\\
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} ���ۣ�}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad���μ���У���˷�֦�˾����������/���ԣ� ����ƽ��ҩ����������ҩ/����ҩ ����������ҩ����������ҩ/����ҩ�� \\\\
		\\hline
		\\end{tabular}
		\\end{table}
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} ˵����}
		\\end{spacing}
		\\begin{enumerate}
		\\item ��������ӫ��PCR���������ڼ���޲��ܱ�֤���Լ����
		
		\\item ���Ͻ��۾�Ϊʵ���Ҽ�����ݣ������ٴ��ο���������Ϊ������Ͻ����
		
		\\item �˱��������Ա����ͼ��������𣬱�����ؽ�������ѯ�ٴ�ҽ����
		\\end{enumerate}
		\\vspace{10ex} % ���ӿ���

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries �������ڣ�$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} ��¼}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} �ο�����}
		\\end{spacing}";
$content_s{'DX1759'}="\\begin{tabular}{|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|} %���ñ����
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{�����} \\\\
		\\hline
		������ & �������� & ����� \\\\
		\\hline
		�������в��� & Influenza A virus & \\\\
		\\hline
		�������в��� & Influenza B virus & \\\\
		\\hline
		\\end{tabular}}
		\\begin{tabular}{|p{1.04\\textwidth}|} %���ñ���ȣ�������������
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} �²���˵����}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad����/�������в�����Influenza A/B virus.��������ճ�����ƣ�Orthomyxoviridae����Ϊ����RNA�����������ֲ�����Ϊ���������в����������ʸߣ������ʸߣ���Ⱦ����ٴ�������Ҫ�з��ȡ�ͷʹ��η�������������ġ���ʹ�����Ժ�ȫ����ʹ�����ز���������ס�����˥�߶�������\$^{[1]}\$��������������֯���������в���ÿ�굼��Լ300��-500�������в�����ÿ�����25����50����������20����סԺ����1977������������H1N1���в�����H1N1��������H3N2���в�����H3N2�����������в�����ȫ��ͬ����\$^{[2]}\$��\\\\
		\\hline
		\\end{tabular}
		\\end{table}
		\\newpage
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} ˵����}
		\\end{spacing}
		\\begin{enumerate}
		\\item ��������ӫ��PCR���������ڼ���޲��ܱ�֤���Լ����
		
		\\item ���Ͻ��۾�Ϊʵ���Ҽ�����ݣ������ٴ��ο���������Ϊ������Ͻ����
		
		\\item �˱��������Ա����ͼ��������𣬱�����ؽ�������ѯ�ٴ�ҽ����
		\\end{enumerate}
		\\vspace{10ex} % ���ӿ���

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries �������ڣ�$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} ��¼}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} �ο�����}
		\\end{spacing}";
$content_s{'DX1760'}="\\begin{tabular}{|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|} %���ñ����
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{�����} \\\\
		\\hline
		������ & �������� & ����� \\\\
		\\hline
		�������ײ��� & Japanese encephalitis virus & \\\\
		\\hline
		\\end{tabular}}
		\\begin{tabular}{|p{1.04\\textwidth}|} %���ñ���ȣ�������������
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} �²���˵����}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad�������ײ�����Japanese encephalitis virus��JEV�����ڻƲ�����(flaviviridae)���������Ϊ��������RNA\$^{[1]}\$���������ײ���( Japanese encephalitis virus, JEV)�ɾ����ó涣ҧ�������ˣ��������ص�������ϵͳ��������Ϊ�������ף������ʸߴ�30\\% \$\\sim\$ 50\\%���ҹ����������е���Ҫ����\$^{[2]}\$��\\\\
		\\hline
		\\end{tabular}
		\\end{table}
		\\newpage
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} ˵����}
		\\end{spacing}
		\\begin{enumerate}
		\\item ��������ӫ��PCR���������ڼ���޲��ܱ�֤���Լ����
		
		\\item ���Ͻ��۾�Ϊʵ���Ҽ�����ݣ������ٴ��ο���������Ϊ������Ͻ����
		
		\\item �˱��������Ա����ͼ��������𣬱�����ؽ�������ѯ�ٴ�ҽ����
		\\end{enumerate}
		\\vspace{10ex} % ���ӿ���

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries �������ڣ�$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} ��¼}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} �ο�����}
		\\end{spacing}";
$content_s{'DX1761'}="\\begin{tabular}{|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|} %���ñ����
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{�����} \\\\
		\\hline
		������ & �������� & ����� \\\\
		\\hline
		��̹���� & Hantavirus & \\\\
		\\hline
		\\end{tabular}}
		\\begin{tabular}{|p{1.04\\textwidth}|} %���ñ���ȣ�������������
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} �²���˵����}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad��̹������һ���а�Ĥ�ֽڶεĸ���RNA���������ڲ����ǲ����ơ���̹������Ϊ���֣�һ������̹�������ۺ�����HPS������һ������̹�������ۺ�����Ѫ�ȣ�HFRS����ǰ����Ҫ������ŷ�����������߼��й��������ɺ�̲������������ۺ�����Ѫ��\$^{[1-2]}\$����̹������̲�͵ķ���֢״��Ҫ����Ϊ���ۺ�����Ѫ�ȣ��Ը��ȡ���Ѫѹ����Ѫ���������������������Ϊ��Ҫ������ \\\\
		\\hline
		\\end{tabular}
		\\end{table}
		\\newpage
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} ˵����}
		\\end{spacing}
		\\begin{enumerate}
		\\item ��������ӫ��PCR���������ڼ���޲��ܱ�֤���Լ����
		
		\\item ���Ͻ��۾�Ϊʵ���Ҽ�����ݣ������ٴ��ο���������Ϊ������Ͻ����
		
		\\item �˱��������Ա����ͼ��������𣬱�����ؽ�������ѯ�ٴ�ҽ����
		\\end{enumerate}
		\\vspace{10ex} % ���ӿ���

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries �������ڣ�$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} ��¼}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} �ο�����}
		\\end{spacing}";
$content_s{'DX1762'}="\\begin{tabular}{|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|} %���ñ����
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{�����} \\\\
		\\hline
		������ & �������� & ����� \\\\
		\\hline
		�²����ǲ��� & New bunyavirus & \\\\
		\\hline
		\\end{tabular}}
		\\begin{tabular}{|p{1.04\\textwidth}|} %���ñ���ȣ�������������
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} �²���˵����}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad���Ȱ�ѪС������ۺ��������ǲ�����SFTSV����ơ��²����ǲ���������һ�����Ρ��а�Ĥ�ĸ��� RNA����\$^{[1,2]}\$�����½���Ѫ�Ȳ�������̹�����������ڲ����ǲ�����\$^{[3]}\$���ò������ҹ����ʡ�ݾ��б������ʸ߶�ɢ�����������ڶ���4-10�·ݣ����и߷�Ϊ5-9�·ݣ�ũ�����������Ұ����ҵ��ȺΪ��Ҫ�׸���Ⱥ�� \\\\
		\\hline
		\\end{tabular}
		\\end{table}
		\\newpage
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} ˵����}
		\\end{spacing}
		\\begin{enumerate}
		\\item ��������ӫ��PCR���������ڼ���޲��ܱ�֤���Լ����
		
		\\item ���Ͻ��۾�Ϊʵ���Ҽ�����ݣ������ٴ��ο���������Ϊ������Ͻ����
		
		\\item �˱��������Ա����ͼ��������𣬱�����ؽ�������ѯ�ٴ�ҽ����
		\\end{enumerate}
		\\vspace{10ex} % ���ӿ���

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries �������ڣ�$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} ��¼}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} �ο�����}
		\\end{spacing}";
$content_s{'DX1783'}="\\begin{tabular}{|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|} %���ñ����
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{�����} \\\\
		\\hline
		������ & �������� & ����� \\\\
		\\hline
		���ٲ��� & Human adenovirus & \\\\
		\\hline
		\\end{tabular}}
		\\begin{tabular}{|p{1.04\\textwidth}|} %���ñ���ȣ�������������
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} �²���˵����}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad���ٲ�����Human adenovirus��HAdV�����ڲ��鶯���ٲ�������HAdV ��Ⱦ��������ּ������������ס�֧�����ס������ס� �۽�Ĥ�ס�θ�������������׵ȡ����������Ⱦ��ص� HAdV ��Ҫ�� B ����(HAdV-3��7��11��14��16��21��50��55 ��)��C ����(HAdV-1��2��5��6��57 ��)�� E ����(HAdV-4 ��)���ٲ�������Լռ��������Է��׵� 4\\%-10\\%����֢������ 3 �ͼ� 7 �Ͷ����HAdV-7B ���� 2019 ���ҹ��Ϸ�����������Ҫ�����ꡣ���ٲ��������Ƕ�ͯ��������Է����н�Ϊ���ص�����֮һ���෢��6������5���ͯ�����ֻ����ٴ������أ����Ⲣ��֢�࣬��֢�������������������ͷμ�������Ŀǰ���Ӥ�׶������������²е���Ҫԭ��֮һ\$^{[1]}\$ �� \\\\ 
		\\hline
		\\end{tabular}
		\\end{table}
		\\newpage
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} ˵����}
		\\end{spacing}
		\\begin{enumerate}
		\\item ��������ӫ��PCR���������ڼ���޲��ܱ�֤���Լ����
		
		\\item ���Ͻ��۾�Ϊʵ���Ҽ�����ݣ������ٴ��ο���������Ϊ������Ͻ����
		
		\\item �˱��������Ա����ͼ��������𣬱�����ؽ�������ѯ�ٴ�ҽ����
		\\end{enumerate}
		\\vspace{10ex} % ���ӿ���

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries �������ڣ�$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} ��¼}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} �ο�����}
		\\end{spacing}";
$content_s{'DX1784'}="\\begin{tabular}{|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|} %���ñ����
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{�����} \\\\
		\\hline
		������ & �������� & ����� \\\\	
		\\hline
		�Ǹ��Ȳ������� & Dengue virus 1 &  \\\\
		\\hline
		�Ǹ��Ȳ������� & Dengue virus 2 &  \\\\
		\\hline
		�Ǹ��Ȳ������� & Dengue virus 3 &  \\\\
		\\hline
		�Ǹ��Ȳ������� & Dengue virus 4 &  \\\\
		\\hline
		\\end{tabular}}
		\\end{table}
		\\begin{table}
		\\begin{tabular}{|p{1.04\\textwidth}|} %���ñ���ȣ�������������
		\\hline
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} �²���˵����}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad�Ǹ��ȣ�Dengue fever, DF�����ɵǸ��Ȳ�����Dengue virus, DENV������ļ��Դ�Ⱦ������Ҫͨ���������úͰ������ô���[1]�� �ٴ�������ҪΪ���ȡ�ͷʹ������͹ؽ�ʹ��Ƥ��ܰͽ��״󼰰�ϸ�����ٵȣ������߿ɳ��ֳ�Ѫ���ݿˣ���������[2,3]�� ���ݿ�ԭ�Բ�ͬ��Ϊ4��Ѫ���� ( DENV-1��DENV-2��DENV-3 �� DENV-4) ��ÿ��Ѫ���� DENV ��������Ǹ��Ⱥ���֢�Ǹ���\$^{[4]}\$ ���� \\\\ 
		\\end{tabular}
		\\begin{tabular}{|p{1.04\\textwidth}|} %���ñ���ȣ�������������
		\\hline
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} ���ۣ�}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad���μ���У��Ǹ��Ȳ��������Ϊ���ԣ�����ͱ�Ϊ���Ǹ��Ȳ������͡��Ǹ��Ȳ������͡��Ǹ��Ȳ������͡��Ǹ��Ȳ������͡� \\\\  \\qquad���μ���У��Ǹ��Ȳ��������Ϊ���ԣ�δ�������Ʒ��ⷶΧ���ͱ�\\\\
		\\hline
		\\end{tabular}
		\\end{table}
		\\newpage
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} ˵����}
		\\end{spacing}
		\\begin{enumerate}
		\\item ��������ӫ��PCR���������ڼ���޲��ܱ�֤���Լ����
		
		\\item ���Ͻ��۾�Ϊʵ���Ҽ�����ݣ������ٴ��ο���������Ϊ������Ͻ����
		
		\\item �˱��������Ա����ͼ��������𣬱�����ؽ�������ѯ�ٴ�ҽ����
		\\end{enumerate}
		\\vspace{10ex} % ���ӿ���

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries �������ڣ�$date}
		
		\\vspace{2cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} ��¼}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} �ο�����}
		\\end{spacing}";
$content_s{'DX1796'}="\\begin{tabular}{|p{0.24\\textwidth}<{\\centering}|p{0.24\\textwidth}<{\\centering}|p{0.24\\textwidth}<{\\centering}|p{0.24\\textwidth}<{\\centering}|} %���ñ����
		\\rowcolor{mygray}\\multicolumn{4}{|c|}{�����} \\\\
		\\hline
		\\rowcolor{mygray}\\multicolumn{2}{|c|}{Sanger������ } & \\multicolumn{2}{c|}{���бȶԽ�� }\\\\
		\\hline
		���� & ������ & ������ & �������� \\\\	
		\\hline	
		�������� & ���� &  &  \\\\
		\\hline
		�������� & ���� & δ��� &  \\\\
		\\hline
		\\end{tabular}}
		\\end{table}
		\\begin{table}
		\\begin{tabular}{|p{1.04\\textwidth}|} %���ñ���ȣ�������������
		\\hline
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} �²���˵����}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad����������Enterovirus, EV������СRNA�����Ƴ���������, ������������ײ�����Poliovirus�������ɲ��� ��Echovirus���������没����Coxsackievirus�����ͳ�������������Ϊֹ���ֵĲ����ͱ���70���֡�����������Ⱦ�ٴ����ָ��Ӷ�䣬�������ز�������ٴ���������ֻ�о뵡�����������ȵȩo���߿�ȫ���Ⱦ�o�ԡ����衢�ġ��ε���Ҫ��������Ԥ��ϲ������������֢�������������Ҫ�ٴ�֢���У���������Ⱦ������ڲ���������Ĥ�ס�������Ƥ���������Ͽ�׵ȡ��ٴ������벡�������벻ͬ�ͱ𲡶���Ⱦ����һ����ϵ����EV71��COXA6��ECHO6��11��18�͵��²�����ǿ�����˺Ͷ�ͯ���ɷ����o��ͯ�϶������֢��Ⱦ����Ϊ7�����¶�ͯ������������ȾҲ�������ͯԺ�е���Ҫ����֮һ�� \\\\ 
		\\hline
		\\end{tabular}
		\\begin{tabular}{|p{1.04\\textwidth}|} %���ñ���ȣ�������������
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} ���ۣ�}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad���μ�⣬�������������Ϊ���ԣ�����ͱ�Ϊ������ \\\\  \\qquad���μ�⣬�������������Ϊ���ԣ�δ�������Ʒ��ⷶΧ���ͱ�\\\\
		\\hline
		\\end{tabular}
		\\end{table}
		\\newpage
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} ˵����}
		\\end{spacing}
		\\begin{enumerate}
		\\item ��������PCR�������Sanger�������Գ����������з��ͼ�⡣
		
		\\item ���ڳ����������ͽ϶࣬���д���ͻ��򲡶������ϵ͡�����������ɼ���������ܵ���PCR �������Ϊ���ԡ�
		
		\\item �������������������ڼ���ޣ�����ʾ�������������������Sanger����ʧ�ܣ��޷����͡�
		
		\\item ���Ͻ��۾�Ϊʵ���Ҽ�����ݣ������ٴ��ο���������Ϊ������Ͻ���������������ٴ���������ʷ������ʵ���Ҽ�鼰���Ʒ�Ӧ������ۺϿ��ǡ�
		
		\\item �˱��������Ա����ͼ��������𣬱�����ؽ�������ѯ�ٴ�ҽ���� 
		
		\\end{enumerate}
		\\vspace{10ex} % ���ӿ���

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries �������ڣ�$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} ��¼}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} �ο�����}
		\\end{spacing}";
		
$content_s{'SD0221'}="\\begin{tabular}{|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|} %���ñ����
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{�����} \\\\
		\\hline
		������ & �������� & ����� \\\\
		\\hline
		2019���͹�״���� & 2019-nCoV & $res{$sid}\\\\
		\\hline
		\\end{tabular}}
		\\begin{tabular}{|p{1.04\\textwidth}|} %���ñ���ȣ�������������
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} �²���˵����}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad2019��12�µף��人�в���ҽ�ƻ���½�����ֲ���ԭ����ײ��ˣ���ר�������Ϊһ�����͹�״����������������֯��WHO���ѽ��˴μ��֮��������Ϊ2019-nCoV��2019���͹�״���������Դ����͹�״�������˽⻹��Ҫ��һ����ѧ�о�����ʵ�ֶԸò����Ŀ���׼ȷ��⣬��Ȼ��һ����Ч�ķ����ֶΡ� \\\\ 
		\\hline
		\\end{tabular}
		\\end{table}
		\\newpage
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} ˵����}
		\\end{spacing}
		\\begin{enumerate}
		\\item ��������ӫ��PCR���������ڼ���޲��ܱ�֤���Լ����
		
		\\item ���Ͻ��۾�Ϊʵ���Ҽ�����ݣ������ٴ��ο���������Ϊ������Ͻ����
		
		\\item �˱��������Ա����ͼ��������𣬱�����ؽ�������ѯ�ٴ�ҽ����
		\\end{enumerate}
		\\vspace{10ex} % ���ӿ���

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries �������ڣ�$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} ��¼}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} �ο�����}
		\\end{spacing}";

$content_s{'DX1867'}="\\begin{tabular}{|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|} %���ñ����
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{�����} \\\\
		\\hline
		������ & �������� & �����\\\\	
		\\hline	
		�������в��� & Influenza A virus,IAV &  \\\\
		\\hline
		�������в��� & Influenza B virus,IBV &  \\\\
		\\hline
		�������ϰ����� & Respiratory syncytial virus, RSV &  \\\\
		\\hline
		���ٲ��� & Human adenovirus, HAdV &  \\\\
		\\hline
		�˱ǲ��� & Human rhinovirus, HRV &  \\\\
		\\hline
		����֧ԭ�� & Mycoplasma Pneumoniae, MP &  \\\\
		\\hline
		\\end{tabular}}
		\\end{table}
		\\newpage
		\\topskip 0.1cm	
	\\begin{longtable}{|p{1.04\\textwidth}|} %���ñ���ȣ�������������
		\\hline
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} �²���˵����}
		\\end{spacing}
		
		\\zihao{-4}\\setlength{\\baselineskip}{18pt}	\\qquad����/�������в�����Influenza A/B virus,IAV/IBV��������ճ�����ƣ�Orthomyxoviridae����Ϊ����RNA�����������ֲ�����Ϊ���������в����������ʸߣ������ʸߣ���Ⱦ����ٴ�������Ҫ�з��ȡ�ͷʹ��η�������������ġ���ʹ�����Ժ�ȫ����ʹ�����ز���������ס�����˥�߶�������\$^{[1]}\$��������������֯���������в���ÿ�굼��Լ300��-500�������в�����ÿ�����25����50����������20����סԺ����1977������������H1N1���в�����H1N1��������H3N2���в�����H3N2�����������в�����ȫ��ͬ����\$^{[2-3]}\$��\\\\

		\\zihao{-4}\\setlength{\\baselineskip}{18pt}	\\qquad�������ϰ�������Respiratory syncytial virus��RSV����һ��RNA���������ڸ�ճ�������ò�����������ĭ�����нӴ�����������Ӥ�׶��º�������Ⱦ����Ҫ��ԭ��Ӥ�׶���ȾRSV��ɷ������ص�ëϸ֧������(���ë֧)�ͷ��ף����ͯ������һ���Ĺ�����Ӥ�׶�֢״���أ����и��ȡ����ס����׼����ף��Ժ����Ϊϸ֧�����׼����ס����������ɲ����ж��ס���Ĥ�׼��ļ��׵ȡ����˺��곤��ͯ��Ⱦ����Ҫ����Ϊ�Ϻ�������Ⱦ\$^{[4]}\$��\\\\

		\\zihao{-4}\\setlength{\\baselineskip}{18pt}	\\qquad���ٲ�����Human adenovirus, HAdV��Ϊ�ް�Ĥ��˫��DNA������Ŀǰ�ѷ�������90�������ͣ���ΪA-G��7����������������Ⱦ��ص�HAdV��Ҫ��B������C������E������HAdV-4�ͣ����ٲ�������Լռ��������Է��׵�4%-10%����֢������3�ͼ�7�Ͷ࣬�Ƕ�ͯ��������Է����н�Ϊ���ص�����֮һ\$^{[5]}\$��\\\\

		\\zihao{-4}\\setlength{\\baselineskip}{18pt}	\\qquad�˱ǲ�����Human rhinovirus��HRV��СRNA�����ơ�����������һ�֣����˻���ͨ��ð����Ҫ��ԭ������ͨ��ð��������Ԥ�������Ʒ�������ʱ������������������Ѫ����˥��֧�������ţ�������ά�������ز���֢������HRV�������������������ϲ���Ⱦ������������ϰ��������ٲ�����\$^{[6]}\$��\\\\

		\\zihao{-4}\\setlength{\\baselineskip}{18pt}	\\qquad����֧ԭ�壨M.Pneumonia��M.p����һ�ִ�С����ϸ���Ͳ���֮����²�΢���֧ԭ����׵Ĳ���ı��Լ����Է���Ϊ������ʱ����֧���ܷ��ף���Ϊԭ���Էǵ����Է��ס���Ҫ����ĭ��Ⱦ��Ǳ����2��3�ܣ�����������������ߡ��ٴ�֢״���ᣬ����������֢״������Ҳֻ��ͷʹ����ʹ�����ȡ����Ե�һ��ĺ�����֢״����Ҳ�и�������������һ���ļ����ɷ���\$^{[7]}\$��\\\\
		\\hline

		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} ���ۣ�}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad���μ���У���������ԭ������Ϊ���ԣ������ԭΪ�������ⲡԭ���ƣ������ֶ����Ҫ�á��������� \\\\  
		\\setlength{\\baselineskip}{18pt}	\\qquad���μ���У���������ԭ������Ϊ���ԣ�δ�������Ʒ��ⷶΧ�ڲ�ԭ��\\\\
		\\hline
		\\end{longtable}
		
		\\newpage
		\\topskip 0.1cm
		\\begin{longtable}{p{1.04\\textwidth}}
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} ˵����}
		\\end{spacing}
		\\begin{enumerate}
		\\item ��������PCR�������Sanger�������Գ����������з��ͼ�⡣
		
		\\item ���ڳ����������ͽ϶࣬���д���ͻ��򲡶������ϵ͡�����������ɼ���������ܵ���PCR �������Ϊ���ԡ�
		
		\\item �������������������ڼ���ޣ�����ʾ�������������������Sanger����ʧ�ܣ��޷����͡�
		
		\\item ���Ͻ��۾�Ϊʵ���Ҽ�����ݣ������ٴ��ο���������Ϊ������Ͻ���������������ٴ���������ʷ������ʵ���Ҽ�鼰���Ʒ�Ӧ������ۺϿ��ǡ�
		
		\\item �˱��������Ա����ͼ��������𣬱�����ؽ�������ѯ�ٴ�ҽ���� 
		
		\\end{enumerate}
		\\vspace{10ex} % ���ӿ���

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries �������ڣ�$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} ��¼}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} �ο�����}
		\\end{spacing}";

$content_s{'DX1868'}="\\begin{tabular}{|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|p{0.33\\textwidth}<{\\centering}|} %���ñ����
		\\rowcolor{mygray}\\multicolumn{3}{|c|}{�����} \\\\
		\\hline
		������ & �������� & �����\\\\	
		\\hline	
		�������в��� & Influenza A virus,IAV &  \\\\
		\\hline
		�������в��� & Influenza B virus,IBV &  \\\\
		\\hline
		�������ϰ����� & Respiratory syncytial virus, RSV &  \\\\
		\\hline
		���ٲ��� & Human adenovirus, HAdV & \\\\
		\\hline
		�˱ǲ��� & Human rhinovirus, HRV &  \\\\
		\\hline
		����֧ԭ�� & Mycoplasma Pneumoniae MP & \\\\
		\\hline
		2019���͹�״����  & 2019-nCoV MP &  \\\\
		\\hline
		\\end{tabular}}
		\\end{table}
		\\newpage
		\\topskip 0.1cm	
	\\begin{longtable}{|p{1.04\\textwidth}|} %���ñ���ȣ�������������
		\\hline
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} �²���˵����}
		\\end{spacing}
		
		\\zihao{-4}\\setlength{\\baselineskip}{16pt}	\\qquad����/�������в�����Influenza A/B virus,IAV/IBV��������ճ�����ƣ�Orthomyxoviridae����Ϊ����RNA�����������ֲ�����Ϊ���������в����������ʸߣ������ʸߣ���Ⱦ����ٴ�������Ҫ�з��ȡ�ͷʹ��η�������������ġ���ʹ�����Ժ�ȫ����ʹ�����ز���������ס�����˥�߶�������\$^{[1]}\$��������������֯���������в���ÿ�굼��Լ300��-500�������в�����ÿ�����25����50����������20����סԺ����1977������������H1N1���в�����H1N1��������H3N2���в�����H3N2�����������в�����ȫ��ͬ����\$^{[2-3]}\$��\\\\

		\\zihao{-4}\\setlength{\\baselineskip}{16pt}	\\qquad�������ϰ�������Respiratory syncytial virus��RSV����һ��RNA���������ڸ�ճ�������ò�����������ĭ�����нӴ�����������Ӥ�׶��º�������Ⱦ����Ҫ��ԭ��Ӥ�׶���ȾRSV��ɷ������ص�ëϸ֧������(���ë֧)�ͷ��ף����ͯ������һ���Ĺ�����Ӥ�׶�֢״���أ����и��ȡ����ס����׼����ף��Ժ����Ϊϸ֧�����׼����ס����������ɲ����ж��ס���Ĥ�׼��ļ��׵ȡ����˺��곤��ͯ��Ⱦ����Ҫ����Ϊ�Ϻ�������Ⱦ\$^{[4]}\$��\\\\

		\\zihao{-4}\\setlength{\\baselineskip}{16pt}	\\qquad���ٲ�����Human adenovirus, HAdV��Ϊ�ް�Ĥ��˫��DNA������Ŀǰ�ѷ�������90�������ͣ���ΪA-G��7����������������Ⱦ��ص�HAdV��Ҫ��B������C������E������HAdV-4�ͣ����ٲ�������Լռ��������Է��׵�4%-10%����֢������3�ͼ�7�Ͷ࣬�Ƕ�ͯ��������Է����н�Ϊ���ص�����֮һ\$^{[5]}\$��\\\\

		\\zihao{-4}\\setlength{\\baselineskip}{16pt}	\\qquad�˱ǲ�����Human rhinovirus��HRV��СRNA�����ơ�����������һ�֣����˻���ͨ��ð����Ҫ��ԭ������ͨ��ð��������Ԥ�������Ʒ�������ʱ������������������Ѫ����˥��֧�������ţ�������ά�������ز���֢������HRV�������������������ϲ���Ⱦ������������ϰ��������ٲ�����\$^{[6]}\$��\\\\

		\\zihao{-4}\\setlength{\\baselineskip}{16pt}	\\qquad����֧ԭ�壨M.Pneumonia��M.p����һ�ִ�С����ϸ���Ͳ���֮����²�΢���֧ԭ����׵Ĳ���ı��Լ����Է���Ϊ������ʱ����֧���ܷ��ף���Ϊԭ���Էǵ����Է��ס���Ҫ����ĭ��Ⱦ��Ǳ����2��3�ܣ�����������������ߡ��ٴ�֢״���ᣬ����������֢״������Ҳֻ��ͷʹ����ʹ�����ȡ����Ե�һ��ĺ�����֢״����Ҳ�и�������������һ���ļ����ɷ���\$^{[7]}\$��\\\\
		
		\\zihao{-4}\\setlength{\\baselineskip}{16pt}	\\qquad2019���͹�״������2019-nCoV����2019���·��ֵ�һ�����͹�״���������ڦ¹�״����������2019���͹�״����������COVID-19���Ĳ�ԭ�壬�������緶Χ�ڹ㷺�����������������ҵ�COVID-19�������ò����Ĵ�Ⱦ�Խ�ǿ��Ǳ����1-14�죬��֢״��Ⱦ��Ҳ���ܳ�Ϊ��ȾԴ����������ĭ���������нӴ���������Ҫ�Ĵ���;�����ò�������COVID-19���ߵĺ����������з��֣������ױ����ڻ��ߵķ�㡢��Һ��Ҳ�м�⵽\$^{[8-11]}\$��\\\\
		\\hline

		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} ���ۣ�}
		\\end{spacing}
		\\zihao{-4}
		\\setlength{\\baselineskip}{18pt}	\\qquad���μ���У���������ԭ������Ϊ���ԣ������ԭΪ�������ⲡԭ���ƣ������ֶ����Ҫ�á��������� \\\\  
		\\setlength{\\baselineskip}{18pt}	\\qquad���μ���У���������ԭ������Ϊ���ԣ�δ�������Ʒ��ⷶΧ�ڲ�ԭ��\\\\
		\\hline
		\\end{longtable}
		
		\\newpage
		\\topskip 0.1cm
		\\begin{longtable}{p{1.04\\textwidth}}
		\\begin{spacing}{1}
		{\\noindent\\hei\\bfseries\\zihao{4} ˵����}
		\\end{spacing}
		\\begin{enumerate}
		\\item ��������PCR�������Sanger�������Գ����������з��ͼ�⡣
		
		\\item ���ڳ����������ͽ϶࣬���д���ͻ��򲡶������ϵ͡�����������ɼ���������ܵ���PCR �������Ϊ���ԡ�
		
		\\item �������������������ڼ���ޣ�����ʾ�������������������Sanger����ʧ�ܣ��޷����͡�
		
		\\item ���Ͻ��۾�Ϊʵ���Ҽ�����ݣ������ٴ��ο���������Ϊ������Ͻ���������������ٴ���������ʷ������ʵ���Ҽ�鼰���Ʒ�Ӧ������ۺϿ��ǡ�
		
		\\item �˱��������Ա����ͼ��������𣬱�����ؽ�������ѯ�ٴ�ҽ���� 
		
		\\end{enumerate}
		\\vspace{10ex} % ���ӿ���

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries �������ڣ�$date}
		
		\\vspace{4cm}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{4} ��¼}
		\\end{spacing}
		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} �ο�����}
		\\end{spacing}";

$content_QM ="
		\\documentclass[UTF8]{ctexart}
		%-------------------------------------------------------------����-------------------------
		\\usepackage[T1]{fontenc} %����text��ʽ�»���
		\\usepackage{lmodern} %����text��ʽ�»���
		\\usepackage{geometry}
		\\usepackage{multirow}
		\\usepackage{float}%������
		\\usepackage{colortbl}%���ñ���и�
		\\definecolor{lightgray}{RGB}{245,245,245}
		\\usepackage{makecell} %���ñ����
		\\usepackage{booktabs} %����ߴ�ϸ
		\\usepackage{fancyhdr}%����ҳüҳ��ҳ���
		\\usepackage{graphicx} % ͼ�κ��
		\\usepackage{colortbl} %�����ɫ��
		\\usepackage{setspace}%ʹ�ü����
		\\usepackage{CJK,CJKnumb} %��������
		\\usepackage{array}%���̶��п����ݾ���
		%\\usepackage{natbib}
		%\\usepackage[superscript]{cite} % �����ϱ�
		\\usepackage[super,square,comma,sort&compress]{natbib}
		\\usepackage[normalem]{ulem}%����»���
		\\usepackage{lastpage}%�����ҳ��
		\\usepackage{enumerate} %�б�
		\\usepackage{enumitem} %�����б���
		\\setlist[enumerate,1]{label=\\arabic*��,leftmargin=7mm,labelsep=1.5mm,topsep=0mm,itemsep=-0.8mm}
		%���ˮӡ
		\\usepackage{tikz}
		\\usepackage{xcolor}
		\\usepackage{eso-pic}
		%���ˮӡ
		\\usepackage{longtable} %����ҳ
		\\usepackage{longtable}
		\\usepackage{tabu}
		\\usepackage{overpic} %������ӻ�����Ϣ
		%------------------------------------------------------����-------------------------------
	%ˮӡ
	\\newcommand\\BackgroundPicture{
		 \\put(0,0){
			\\parbox[b][\\paperheight]{\\paperwidth}{
				\\vfill
				      \\centering
					  \\begin{tikzpicture}[remember picture,overlay]
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at (current page.center) {\\textcolor{gray!80!cyan!30}{PMseq}};
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=5cm,yshift=0cm]current page.west) {\\textcolor{gray!80!cyan!30}{PMseq}};
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=-5cm,yshift=0cm]current page.east) {\\textcolor{gray!80!cyan!30}{PMseq}};

					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=0cm,yshift=-7cm]current page.north) {\\textcolor{gray!80!cyan!30}{PMseq}};
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=-5cm,yshift=-7cm]current page.north east) {\\textcolor{gray!80!cyan!30}{PMseq}};
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=5cm,yshift=-7cm]current page.north west) {\\textcolor{gray!80!cyan!30}{PMseq}};

					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=0cm,yshift=7cm]current page.south) {\\textcolor{gray!80!cyan!30}{PMseq}};
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=5cm,yshift=7cm]current page.south west) {\\textcolor{gray!80!cyan!30}{PMseq}};
					  \\node [rotate=60,scale=4,text opacity=0.5,font=\\fontsize{10}{10}\\selectfont] at ([xshift=-5cm,yshift=7cm]current page.south east) {\\textcolor{gray!80!cyan!30}{PMseq}};

			\\end{tikzpicture}
			\\vfill
			}
		}
	}
%ˮӡ
		\\definecolor{mygray}{gray}{.9}
		\\definecolor{myback}{gray}{.9}
		\\definecolor{myblue}{RGB}{0,74,143}
		\\definecolor{myorange}{RGB}{243,152,0}
		%\\definecolor{myback}{RGB}{252,228,214}
		%\\newCJKfontfamily\\msyh{΢���ź�}
		%\\setCJKfamilyfont{yh}{Microsoft YaHei}


		\\newcommand{\\song}{\\CJKfamily{song}}    % ����
		\\newcommand{\\fs}{\\CJKfamily{fs}}             % ������
		\\newcommand{\\kai}{\\CJKfamily{kai}}          % ����
		\\newcommand{\\hei}{\\CJKfamily{hei}}         % ����
		\\newcommand{\\li}{\\CJKfamily{li}}               % ����

		%-----------------------------------------------����-------------------------
		\\geometry{a4paper,centering,scale=0.8}
		\\pagestyle{fancy} %����ҳüҳ��
		%\\graphicspath{{C:/Users/mabingyin/Desktop/Plus��ƷС����/Plus��ƷС����汾����/V2.2/TJ/}}
		\\graphicspath{{C:/CTEX/Pictures/}}

		%-------------------------------------------------ҳü����ͼƬ-------------
		\\newsavebox{\\headpic}
		\\sbox{\\headpic}{\\includegraphics[height=2cm]{Y13-qPCR-XJNY-191028-QM.jpg}} %����ҳülogoҳü
		\\fancyhead[l]{\\usebox{\\headpic}}
		 
		\\fancyhead[c]{\\zihao{-5}������$name \\hspace{10cm}  �������ڣ�$collect_date }
		%--------------------------------------------------����---------------------

		%----------------------------------------------����ҳüҳ�Ÿ�ʽ------------
		
		\\rhead{\\zihao{-5} \\uline{\\hspace{14cm}DX-PMP-B60 V1.1} \\vspace{0.1ex}   }
		 \\lfoot{\\zihao{-5} �ͷ��绰��400-6057-268  \\hspace{0.8cm} ��ַ:www.cmlabs.com.cn}
		\\cfoot{}%�и����ҳ���м䲻����ҳ��
		%\\rfoot{\\thepage}
		\\rfoot{\\thepage \\ / \\pageref{LastPage}}
		\\renewcommand{\\headrulewidth}{0.2pt}%��Ϊ0pt����ȥ��ҳ������ĺ���   
		\\renewcommand{\\footrulewidth}{0.2pt}
		%-------------------------------------------------����--------------------
		\\setlength{\\extrarowheight}{4mm} %����и�

		%------------------------------------------��ʼ����--------------------------
		\\begin{document}
		\\bibliographystyle{unsrt} % �����������������õ�˳������
	
		%-----------------------------------------��ҳ����ͼƬ----------------------
		\\newgeometry{left=0.8cm,bottom=0cm,right=0.8cm,top=0cm} %���ĵ���ҳ��ҳ�߾� 
		\\setcounter{page}{0} %ҳ��1�ӵڶ�ҳ��ʼ
		\\thispagestyle{empty} %��ҳ����ʾҳüҳ��
		\\begin{overpic}[width=\\textwidth,height=\\textheight,,keepaspectratio]{F13-qPCR-XJNY-191129-QM.png} 
		\\put(21,10){\\begin{tabular}{cp{270 pt}<{\\centering}}%19
		\\cline{2-2}
		\\textcolor{myorange}{\\zihao{3}\\bfseries $hospital}\\\\ 
		
		\\cline{2-2}
		\\end{tabular}}
		\\end{overpic}
		\\restoregeometry %�ָ���ԭ����ҳ�߾�
		%------------------------------------------------------����-----------------------------
		\\newpage
		\\topskip 1.5cm
		%\\vspace{6mm}%ҳü���������ļ�Ĵ�ֱ���

		\\noindent %���񣬲�����
		{\\hei\\zihao{4}\\bfseries һ \\quad ������Ϣ} %�������ʹ�þ���ҳü�ľ���������һ����
		%-------------------------------------------------------��ʼ���-----------------------------------------------------
		\\begin{table}[H]
		\\zihao{-5}{\\bfseries
		\\renewcommand\\arraystretch{0.95} %���ñ���и�
		\\begin{tabular}{p{0.33\\textwidth}p{0.33\\textwidth}p{0.33\\textwidth}} %���ñ����
		\\hline
		\\rowcolor{orange!35}\\multicolumn{3}{l}{�ܼ�����Ϣ} \\\\%���ߵ����ã�
		\\hline
		������$name & �Ա�$sex & ���䣺 $age \\\\
		\\hline
		סԺ�ţ�$hosnum & ���ţ�$bednum & ԭ������ţ� $origin_id  \\\\
		\\hline
		\\rowcolor{orange!35}\\multicolumn{3}{l}{�ٴ���Ϣ} \\\\
		\\hline
		\\multicolumn{3}{p{\\textwidth}}{ �ٴ����֣�$manifestation} \\\\
		\\hline
		\\multicolumn{3}{p{\\textwidth}}{�ٴ����} \\\\
		\\hline
		\\end{tabular}
		\\begin{tabular}{p{0.243\\textwidth}p{0.24\\textwidth}p{0.24\\textwidth}p{0.24\\textwidth}} %���ñ���ȣ�
		ѪWBC��$wbc & �Լ�ҺWBC��$ly & �ظ�ˮWBC��$neu & CRP��$crp \\\\
		\\hline
		PCT��$pct & ���������$culture & ���������$identify & ��������$microscopy \\\\
		\\hline
		
		\\multicolumn{4}{p{\\textwidth}}{�ٴ���ϣ�$diagnosis} \\\\
		\\hline
		\\multicolumn{4}{p{\\textwidth}}{�ص��ע��ԭ��$pathogen} \\\\
		\\hline
		\\multicolumn{4}{p{\\textwidth}}{����Ⱦ��ҩ��$drug} \\\\
		\\hline
		\\rowcolor{orange!35}\\multicolumn{4}{l}{������Ϣ} \\\\
		\\end{tabular}
		\\begin{tabular}{p{0.33\\textwidth}p{0.33\\textwidth}p{0.33\\textwidth}} %���ñ����
		\\hline
		�ͼ쵥λ��$hospital & �ͼ���ң�$department & �ͼ�ҽʦ��$doctor  \\\\
		\\hline
		�������ڣ�$collect_date & �������ڣ�$recept_date & �������ڣ�$date \\\\
		\\hline
		������ţ�$sid & �������ͣ�$sptype &  ���������$spvolume  \\\\
	     \\hline
		\\end{tabular}}
		\\end{table}
		
		\\vspace{5ex} % ���ӿ���
		\\noindent %���񣬲�����		
		{\\hei\\zihao{-4}\\bfseries �� \\quad �����} %�������ʹ�þ���ҳü�ľ���������һ����
		%-------------------------------------------------------��ʼ���-----------------------------------------------------
		\\topskip 0cm
		{\\song\\bfseries\\zihao{-5} %�������
	\\begin{longtable}
		{p{0.24\\textwidth}p{0.24\\textwidth}p{0.24\\textwidth}p{0.24\\textwidth}}
		\\toprule[0.1pt]

		\\multicolumn{4}{>{\\columncolor{orange!35}}l}{\\zihao{-5}�����}   \\\\
		\\midrule
		{\\zihao{4}} ��ҩ���� & ��Ӧø & ��ҩ�� & �����  \\\\
		\\midrule
		CTX-M1 & ��-������ø & �ɵ��°�Ī���֡��������֡�ͷ��߻����ͷ����뿡��ȷ�ù����ҩ�￹�ԣ��԰�����Ҳ�п��� & \\\\
		\\midrule
		KPC & ̼��ùϩø & �ɵ����ǰ����ϡ��������ϡ��������֡�ͷ�������ơ�ͷ����뿡������ϡ��������֡�ͷ����뿡�ͷ����ड��������ϵȿ��� & \\\\
		\\midrule
		IMP & ������-������ø & �ɵ��°������֡��濨���֡�ͷ��������ͷ����ड��ǰ����ϡ��������ϵ�̼��ùϩ�࣬ͷ�߾�����ҩ�￹�� & \\\\
		\\midrule
		VIM & ������-������ø & �ɵ���ͷ��������ͷ�������ơ�ͷ��������ͷ����ड��ǰ����ϡ��������ϵ�̼��ùϩ�࣬ͷ�߾�����ҩ�￹�� & \\\\
		\\midrule
		NDM & ������-������ø & �ɵ���ͷ����뿡�ͷ����ड�ͷ�������ơ��������ϡ��������ϡ��ǰ����ϵȿ��� & \\\\
		\\midrule
		SIM & ������-������ø & �ɵ���ͷ�߾����ࡢ̼��ùϩ��ҩ�￹�� & \\\\
		\\midrule
		DIM & ������-������ø & �ɵ���ͷ����������Ī���֡��濨���֡��������֡�ͷ����뿡��ǰ����ϵȿ��� & \\\\
		\\midrule
		%\\bottomrule[1.2pt]
	\\end{longtable}}
          
		\\noindent\\zihao{5}{\\song\\bfseries ���˵����}
 
		{\\zihao{5}{\\song��������������ⶨ�Լ�⵼��ϸ����ҩ��ص���ø���򣬰��������ͳ����צ�-������ø��CTX-M1�ͱ��������̼��ùϩ����ҩ̼��ùϩø������򣬼����λ�������ϵ�̼��ùϩø�����A�ࣨKPC����B�ࣨIMP,VIM,NDM,SIM,DIM����7����ҩ��ػ���Ϊϸ����ҩ���ߵ������ṩ�����ֶΡ�\\\\}}

		\\noindent\\zihao{5}{\\song\\bfseries ���ۣ�}

		\\zihao{5}{\\song���μ���У�ϸ����ҩ�����Ϊ���ԣ������ҩ����CTX-M1/KPC/ IMP/VIM/NDM/SIM/DIM���ɵ���ҩ�￹�Լ��������ҩ�ס����μ���У�ϸ����ҩ�����Ϊ���ԣ�δ�������Ʒ��ⷶΧ�ڵ���ҩ����\\\\}

		\\begin{spacing}{1.5}
		{\\noindent\\song\\bfseries\\zihao{-4} �ο�����}
		\\end{spacing}
		
		{\\noindent\\zihao{5} 1.	Anjum M F , Zankari E , Hasman H . Molecular Methods for Detection of Antimicrobial Resistance[J]. Microbiology Spectrum, 2017, 5(6).}

		{\\noindent\\zihao{5} 2.	Mcdonald L C , Kuehnert M J , Tenover F C , et al. Vancomycin-resistant enterococci outside the health-care setting: prevalence, sources, and public health implications.[J]. Emerging Infectious Diseases, 1997, 3(3):311.}

		{\\noindent\\zihao{5} 3.	�����.ʵʱӫ��PCR����.�����ҽ�����磬2007.  }

		{\\noindent\\zihao{5} 4.	�����,�,���Ļ�,����,���ֲ�.ϸ����bla\\_(NDM-1)�������ɵ��о���չ[J].������ѧ,2018,30(11):1244-1251. }

		{\\noindent\\zihao{5} 5.	������,�⿡ΰ,������.ϸ����ҩ�Բ����ķ�������ѧ�������ƴ�ʩ[J].����ҽѧ��չ,2008(02):106-109. }

		{\\noindent\\zihao{5} 6.	Murakami K , Minamide W , Wada K , et al. Identification of methicillin-resistant strains of staphylococci by polymerase chain reaction.[J]. Journal of Clinical Microbiology, 1991, 29(10):2240-2244. }

		{\\noindent\\zihao{5} 7.	������,���ƽ�,�����,������,���.̼��ùϩ����ҩ���˾���ϸ�������ͼ�⼰��ҩ�Է���[J].�ٴ�������־,2018,36(09):663-666. }

		{\\noindent\\zihao{5} 8.	Dallenne C , Costa A D , Dominique Decr��, et al. Development of a set of multiplex PCR assays for the detection of genes encoding important beta-lactamases in Enterobacteriaceae.[J]. Journal of Antimicrobial Chemotherapy, 2010, 65(3):490. }

		{\\noindent\\zihao{5} 9.	Solanki R , Vanjari L , Subramanian S , et al. Comparative Evaluation of Multiplex PCR and Routine Laboratory Phenotypic Methods for Detection of Carbapenemases among Gram Negative Bacilli.[J]. J Clin Diagn Res, 2014, 8(12):23-6. }

		{\\noindent\\zihao{5} 10.	Poirel L , Walsh T R , Cuvillier V , et al. Multiplex PCR for detection of acquired carbapenemase genes[J]. Diagnostic Microbiology and Infectious Disease, 2011, 70(1):0-123. }

		\\vspace{20ex} % ���ӿ���
		\\topskip 0.1cm
		\\begin{spacing}{1.5}
		{\\noindent\\hei\\bfseries\\zihao{4} �� \\quad ������}
		\\end{spacing}
		\\begin{enumerate}
		\\item ��������ӫ��PCR���������ڼ���޲��ܱ�֤���Լ����
		\\vspace{2ex}
		\\item ���Ͻ��۾�Ϊʵ���Ҽ�����ݣ������ٴ��ο���������Ϊ������Ͻ����
		\\vspace{2ex}
		\\item �˱��������Ա����ͼ��������𣬱�����ؽ�������ѯ�ٴ�ҽ����
		\\end{enumerate}
		\\vspace{10ex} % ���ӿ���

		{\\zihao{6}\\color{white} \\hspace{12cm}\\\$result\\_seal\\_user\\_flag\\_7\\\$}\\\\
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_15\\\$}
		{\\song\\zihao{-4}\\bfseries ����ߣ�}{\\zihao{6}\\color{white}\\\$result\\\_seal\\\_user\\\_flag\\\_29\\\$}
		{\\song\\zihao{-4}\\bfseries �������ڣ�$date}
		\\end{document}";


$content_r{'DX1749'}="
{\\noindent\\zihao{5}[1] �̾�ΰ, ���Ķ�, ��С��,��. �й����˼��������Ⱦ��Ϻ�����ר�ҹ�ʶ[J]. Э��ҽѧ��־, 2017, 8(2):131-138.}

{\\noindent\\zihao{5}[2] ��ܷ, ����. ���������Ⱦ������о���չ[J]. �ٴ���������, 2015(8):105-108.}

{\\noindent\\zihao{5}[3] ������. ��ͬ��Դ�ļ�������䶾�ء�MLST���ͼ�ҩ������ķ���[D]. �Ϸ�ҽ�ƴ�ѧ, 2016. }

{\\noindent\\zihao{5}[4] ����, ����, ����ǫ,��. ʵʱӫ��PCR���ټ�����м����������[J]. �й�����������־, 2011(7):1604-1606. }

\\end{document}
";

$content_r{'DX1763'}="
{\\noindent\\zihao{5}[1] ������.���ٴ����в�ѧ���������������磬2002��}

{\\noindent\\zihao{5}[2] �����. ����ڲ����в�ѧ����ضԲ�.��������ҽҩ. 2008��}

{\\noindent\\zihao{5}[3] �л����񹲺͹�������.����ڲ�����ָ�� (2008���)��\\\\ http://www.gov.cn/gzdt/2008-12/12/content\\_1176057.htm  }

{\\noindent\\zihao{5}[4] Xiao XL et al. Simultaneous detection of human enterovirus71 and coxsackievirus A16 in clinical specimens by multiplex real-time PCR with an internal amplification control. }

\\end{document}
";
$content_r{'DX1759'}="
{\\noindent\\zihao{5}[1] �¼���,��Ԫ��.���������Ը�ð����������ϵ����Դ�����ݱ�����. ����ѧ��2001(4).}

{\\noindent\\zihao{5}[2] ��Ծ����. 2004-2005���й�A��H1N1���������в�����ԭ�Լ����������о����ٴ�ҽѧ��2006��}

{\\noindent\\zihao{5}[3] ����,��Ԫ��. ��ǰ���е��������в���Ѫ���ص��׿�ԭ�Լ����������. ���л�ʵ����ٴ�����ѧ��־��1995(3).}

{\\noindent\\zihao{5}[4] Novel Swine-Origin Influenza A (H1N1) Virus Investigation Team. Emergence of a Novel Swine-Origin Influenza A (H1N1) Virus in Humans. N Engl J Med��2009.}

{\\noindent\\zihao{5}[5] M W Shaw, R A Lamb, and P W Choppin. Proc Natl Acad Sci U S A. 1982 ;79(22). }

{\\noindent\\zihao{5}[6] Yamashita M, Krystal M, Fitch WM, Palese P. Influenza B virus evolution: co-circulating lineages and comparison of evolutionary pattern with those of influenza A and C viruses. Virology. 1988;163(1).}

\\end{document}
";

$content_r{'DX1760'}="
{\\noindent\\zihao{5}[1] �ŵ�, ������, ����һ��. �������ײ�����������ѧ���Լ���ⷽ���о���չ[J]. �й��������. 2009,26:70-72.}

{\\noindent\\zihao{5}[2] ������, ��ʿ��, �κ��. �������ײ��� TaqMan PCR ��ⷽ���Ľ���������Ӧ��[J]. �л�΢����ѧ������ѧ��־. 2007,22:420-422.}

{\\noindent\\zihao{5}[3] M. M. Parida, S. R. Santhosh, P. K. Dash, N. K. Tripathi, P. Saxena, S. Ambuj, A. K. Sahni, P. V. Lakshmana Rao and Kouichi Morita. Development and Evaluation of Reverse Transcription�CLoop-Mediated Isothermal Amplification Assay for Rapid and Real-Time Detection of Japanese Encephalitis Virus [J].Journal of Clinical Microbiology��2006, 44:4172-4178.}

\\end{document}
";

$content_r{'DX1761'}="
{\\noindent\\zihao{5}[1] ������, ��ռ��, Ф���. RT-PCR������̲����������������еķ���������[J]. �л�΢����ѧ������ѧ��־. 2003,23: 38-41.}

{\\noindent\\zihao{5}[2] �����ģ������٣�������. �ҹ���̹���������ͺͻ������͵ķֲ��о�[J]. ����ѧ��. 2002�� 18��211-216.}

{\\noindent\\zihao{5}[3] Mohamed. Aitichou, Sharron.S.Saleh, Anita.K, McElroy, C. Schmaljohn, M.Sofi.Ibrahim. Identification of Dobrava, Hantaan, Seoul, and Puumala viruses by one-step real-time RT-PCR[J].Journal of Virological Methods. 2005, 124:21-26.}

{\\noindent\\zihao{5}[4] Wei Jiang, Hai-tao Yu, Ke Zhao, Ye Zhang, Hong Du, Ping-zhong Wang, Xue-fan Bai. Quantification of Hantaan Virus with a SYBR Green I-Based One-Step qRT-PCR Assay[J]. PLOS ONE. 2013. 8(11):1-9. }

\\end{document}
";

$content_r{'DX1762'}="
{\\noindent\\zihao{5}[1]  ������,��ӱ,����,�޶���. ���Ȱ�ѪС������ۺ��������ǲ����о���չ[J]. ΢����ѧ��־,2013,02:86-88.}

{\\noindent\\zihao{5}[2] ����ӱ,��Цˬ,��ѧ��. ���Ȱ�ѪС������ۺ��������ǲ����о���չ[J]. �й���������,2014,07:967-971.}

{\\noindent\\zihao{5}[3] ��ӱ,�۰�,�ڳ���,������,������,�ﱦ��. �����ǲ����Ƹ���[J]. �й�ý������ѧ��������־,2012,02:182-184.}

{\\noindent\\zihao{5}[4] ʩ��,���ٱ�,ʯƽ,���ƻ�,̷����,�ܽ���,Ǯ�໪. ���Ͳ����ǲ�����Ⱦ�����ٴ���Ѫ�����в�ѧ��������[J]. �Ͼ�ҽ�ƴ�ѧѧ��(��Ȼ��ѧ��),2015,03:433-435. }

\\end{document}
";
$content_r{'DX1757'}="
{\\noindent\\zihao{5}[1] �����񡣽�˲�����ʵ���Ҽ�������״��չ�����л�����ҽѧ��־��2001��24(2)��71-72.}

{\\noindent\\zihao{5}[2] ��Ч�ѣ���������Tag Man�ۺ�ø����Ӧ��������˷�֦�˾�DNA���ٴ�Ӧ�á��л���˺ͺ�����־��2000��23(5)��283-288��}

{\\noindent\\zihao{5}[3] �����ڡ�ӫ�ⶨ���ۺ�ø����Ӧ��Ͻ�˲��ٴ�Ӧ���о���ɽ��ҽ�ƴ�ѧѧ����2006.37(2)��180-181��}

{\\noindent\\zihao{5}[4] Kocagoz T��Ozkara S��Ozkara S��Detection of mycobacterium tuberculosis in sputum samples by polymerase chain reaction using a simplified procedure[J]. Chin Microbiology��1993��31(6)��1435��}

{\\noindent\\zihao{5}[5] �ܲ�ȫ���콨�壬��ӭ������˷�֦�˾��걾�Ĳ�ͬ��������PCR���������Ե�Ӱ�졣�ִ�ҽѧ������־��2005��20(6)��60-63��}

{\\noindent\\zihao{5}[6] �ܻԣ���־ƽ���Ӱ��ơ��ظ�ˮ�Լ�Һ�н�˸˾��ļ�⡣ʵ��Ԥ��ҽѧ��2005,12(1)��63-64��}

\\end{document}
";
$content_r{'DX1758'}="
{\\noindent\\zihao{5}[1]  Anjum M F , Zankari E , Hasman H . Molecular Methods for Detection of Antimicrobial Resistance[J]. Microbiology Spectrum, 2017, 5(6).}

{\\noindent\\zihao{5}[2] Mcdonald L C , Kuehnert M J , Tenover F C , et al. Vancomycin-resistant enterococci outside the health-care setting: prevalence, sources, and public health implications.[J]. Emerging Infectious Diseases, 1997, 3(3):311.}

{\\noindent\\zihao{5}[3] �����.ʵʱӫ��PCR����.�����ҽ�����磬2007.}

{\\noindent\\zihao{5}[4] �����,�,���Ļ�,����,���ֲ�.ϸ����bla\\_(NDM-1)�������ɵ��о���չ[J].������ѧ,2018,30(11):1244-1251.}

{\\noindent\\zihao{5}[5] ������,�⿡ΰ,������.ϸ����ҩ�Բ����ķ�������ѧ�������ƴ�ʩ[J].����ҽѧ��չ,2008(02):106-109.}

{\\noindent\\zihao{5}[6] Murakami K , Minamide W , Wada K , et al. Identification of methicillin-resistant strains of staphylococci by polymerase chain reaction.[J]. Journal of Clinical Microbiology, 1991, 29(10):2240-2244.}

{\\noindent\\zihao{5}[7] ������,���ƽ�,�����,������,���.̼��ùϩ����ҩ���˾���ϸ�������ͼ�⼰��ҩ�Է���[J].�ٴ�������־,2018,36(09):663-666.}

{\\noindent\\zihao{5}[8] Dallenne C , Costa A D , Dominique Decr��, et al. Development of a set of multiplex PCR assays for the detection of genes encoding important beta-lactamases in Enterobacteriaceae.[J]. Journal of Antimicrobial Chemotherapy, 2010, 65(3):490.}

{\\noindent\\zihao{5}[9] Solanki R , Vanjari L , Subramanian S , et al. Comparative Evaluation of Multiplex PCR and Routine Laboratory Phenotypic Methods for Detection of Carbapenemases among Gram Negative Bacilli.[J]. J Clin Diagn Res, 2014, 8(12):23-6.}

{\\noindent\\zihao{5}[10] Poirel L , Walsh T R , Cuvillier V , et al. Multiplex PCR for detection of acquired carbapenemase genes[J]. Diagnostic Microbiology and Infectious Disease, 2011, 70(1):0-123.}

\\end{document}
";
$content_r{'DX1783'}="
{\\noindent\\zihao{5}[1]  ��ͯ�ٲ����������ƹ淶(2019 ���).}

\\end{document}
";
$content_r{'DX1784'}="
{\\noindent\\zihao{5}[1] ������, ����Ӣ, Ҷ�̷��. ʵʱӫ�ⶨ��PCR �ڵǸ��Ȳ������ټ���е�Ӧ��[J]. �й���ԭ����ѧ��־��2008,3��12��: 897-899.}

{\\noindent\\zihao{5}[2] ��־��������ΰ�������޵�. TaqManӫ�ⶨ��PCR���1�͵Ǹ��Ȳ������ٴ�Ӧ��[J]. �й�ý������ѧ��������־��2010,21��3��: 229-231-422.}

{\\noindent\\zihao{5}[3] л������ͮ��̷���������Σ���ķ�. �Ǹ���147���ٴ��ص����[J]. ���ϼ���ҽѧ��־��2003��01:22-23.}

{\\noindent\\zihao{5}[4] ������������������ʤ����. �Ǹ��Ȳ�������ӫ��PCR ��⼰������ͷ������о�[J]. �ȴ�ҽѧ��־��2012, 12��8��: 936-939.}

{\\noindent\\zihao{5}[5] �л�ҽѧ���Ⱦ��ѧ�ֻ�, �л�ҽѧ���ȴ����������ѧ�ֻ�, �л���ҽҩѧ�ἱ��ֻ�, et al. �й��Ǹ����ٴ���Ϻ�����ָ��[J]. ��Ⱦ����Ϣ, 2018, 31(05):7-14.}


\\end{document}
";
$content_r{'DX1796'}="
{\\noindent\\zihao{5}[1] �����࣬�����ᣬ����.�����������ӷ����о���չ.�й�������־��2012.2��1����72-76.}

{\\noindent\\zihao{5}[2] Leitch EC, Harvala H, Robertson I, et al. Direct dentification of human enterovirus serotypes in cerebrospinal fluid by amplification and sequencing of the VP1 region[J].J Clin Virol, 2009, 44 (2)��119-124.}

{\\noindent\\zihao{5}[3] Hu YF, Yang F, Du J, et al. Complete genome analysis of coxsackie viurs A2, A4, A5, and A10 strains isolated from hand, foot, and mouth disease patients in China revealing frequent      recombination of human enterovirus A[J].J Clin Microbiol, 2011, 49 (7) :2426-2434.}

{\\noindent\\zihao{5}[4] ���ȣ���С�䣬��ٻ��. ����VP4���������н��г����������͵Ŀ������о�.Ԥ��ҽѧ�鱨��־��2016��5��.}

\\end{document}
";

$content_r{'DX1867'}="

{\\noindent\\zihao{5}[1] Yamashita M, Krystal M, Fitch WM, Palese P. Influenza B virus evolution: co circulating lineages and comparison of evolutionary pattern with those of influenza A and C viruses. Virology[J]. 1988,163(1).112~122.}

{\\noindent\\zihao{5}[2] ��Ծ����. 2004-2005���й�A��H1N1���������в�����ԭ�Լ����������о�[J].�ٴ�ҽѧ, 2006,20(2):27~29.}

{\\noindent\\zihao{5}[3] �¼���, ��Ԫ��. ���������Ը�ð����������ϵ����Դ�����ݱ�����[J]. ����ѧ��, 2001,17(4):322~327.}

{\\noindent\\zihao{5}[4] ����, �����. �������ϰ�������Ⱦ��������[J]. �л�������־ 2006,44(9):673~675.}

{\\noindent\\zihao{5}[5] ���ľ�, ����, ���о�. ���ٲ������о���չ[J]. ����ѧ��, 2014,30(2):193~200.}

{\\noindent\\zihao{5}[6] ������, ë��ӱ, �������. �˱ǲ������о���չ[J]. ����ѧ��, 2011,27(3):294~297.}

{\\noindent\\zihao{5}[7] ½Ȩ, ½��. ����֧ԭ���Ⱦ�����в�ѧ[J]. ʵ�ö����ٴ���־, 2007,22(4):241~243.}

\\end{longtable}
\\end{document}
";

$content_r{'DX1868'}="

{\\noindent\\zihao{5}[1] Yamashita M, Krystal M, Fitch WM, Palese P. Influenza B virus evolution: co circulating lineages and comparison of evolutionary pattern with those of influenza A and C viruses. Virology[J]. 1988,163(1).112~122.}

{\\noindent\\zihao{5}[2] ��Ծ����. 2004-2005���й�A��H1N1���������в�����ԭ�Լ����������о�[J].�ٴ�ҽѧ, 2006,20(2):27~29.}

{\\noindent\\zihao{5}[3] �¼���, ��Ԫ��. ���������Ը�ð����������ϵ����Դ�����ݱ�����[J]. ����ѧ��, 2001,17(4):322~327.}

{\\noindent\\zihao{5}[4] ����, �����. �������ϰ�������Ⱦ��������[J]. �л�������־ 2006,44(9):673~675.}

{\\noindent\\zihao{5}[5] ���ľ�, ����, ���о�. ���ٲ������о���չ[J]. ����ѧ��, 2014,30(2):193~200.}

{\\noindent\\zihao{5}[6] ������, ë��ӱ, �������. �˱ǲ������о���չ[J]. ����ѧ��, 2011,27(3):294~297.}

{\\noindent\\zihao{5}[7] ½Ȩ, ½��. ����֧ԭ���Ⱦ�����в�ѧ[J]. ʵ�ö����ٴ���־, 2007,22(4):241~243.}

{\\noindent\\zihao{5}[8] Lu R, Zhao X, Li J et al.. Genomic characterisation and epidemiology of 2019 novel coronavirus: implications for virus origins and receptor binding. Lancet. 2020 Feb 22;395(10224):565-574.}

{\\noindent\\zihao{5}[9] Zhu N, Zhang D, Wang W, et al.. A Novel Coronavirus from Patients with Pneumonia in China, 2019. N Engl J Med. 2020 Feb 20;382(8):727-733.}

{\\noindent\\zihao{5}[10] Xie C, Jiang L, Huang G, et al.. Comparison of different samples for 2019 novel coronavirus detection by nucleic acid amplification tests. Int J Infect Dis. 2020 Feb 27;93:264-267.}

{\\noindent\\zihao{5}[11] Ling Y, Xu SB, Lin YX, et al.. Persistence and clearance of viral RNA in 2019 novel coronavirus disease rehabilitation patients. Chin Med J (Engl). 2020 Feb 28. doi: 10.1097/CM9.0000000000000774. [Epub ahead of print]}

\\end{longtable}
\\end{document}
";

$content_r{'SD0221'}="

{\\noindent\\zihao{5}[1] ����}

\\end{document}
";
	if ($hospital =~ /ǧ��/){
		print OUT encode("utf8",decode("gbk",$content_QM));
	}
	else{
		print OUT encode("utf8",decode("gbk",$content_1));
		print OUT encode("utf8",decode("gbk",$content_s{${version}}));
		print OUT encode("utf8",decode("gbk",$content_r{${version}}));
	}
}

{
	$| = 1; my $i = 10; while($i){ print "�Զ���ȡ����ɣ���رճ���($i����Զ��ر�)\r"; $i--; sleep(1); }
}

#============================sub routine=====================

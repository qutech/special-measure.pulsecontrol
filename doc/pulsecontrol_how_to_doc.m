%% How to extend and modify this documentation using |publish()|
% This documentation follows MATLAB(R) guidelines defined in
% <http://www.mathworks.de/de/help/matlab/matlab_prog/display-custom-documentation.html Custom Documentation>.
% 
%% Short summary of the documentation structure
% * The content uses <http://www.mathworks.de/de/help/matlab/matlab_prog/marking-up-matlab-comments-for-publishing.html html-markup> for styling
% * The topics are seperated into m-files, which are parsed with |publish()| to generate html-files
% * The html-files are linked together in the html/..._product_page.html
% * html/helptoc.xml provides links to main topics in the documentation browser tree-view
% * info.xml directs MATLAB(R) to the html/ folder containing all documentation files
%
% The m-files of the existing topics are provided as guidiance to write new topics.
% Existing spelling mistakes or contentual errors should also be corrected inside the m-files.
% The files must then be re-published as discussed below.
%
%% How to publish an m-file
% The |publish()| function is used with the following options:
%
opts = struct('outputDir', fileparts(which('pulsecontrol_features.m')),...
			  'evalCode', false,...
			  'stylesheet', [fileparts(which('pulsecontrol_features.m')) '/mxdom2simplehtml.xsl']);

publish('pulsecontrol_how_to_doc.m', opts);

%%
% This would re-publish the document you are reading right now,
% if the current folder is the html/ directory containing this documentation.
%% 
% The opts structure contains important options for the publish function.
% A commun stylesheet mxdom2simplehtml.xsl is used throughout all created html-files to enshure a homogenous layout throughout MATLAB(R) versions.
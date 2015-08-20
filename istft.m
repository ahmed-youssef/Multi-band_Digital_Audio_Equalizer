function x = istft(d, dft_length, win)

if nargin < 2; dft_length = 256; end
if nargin < 3; win = ones(1,dft_length); end

% expect win as a row
if size(win,1) > 1
  win = win';
end

s = size(d);

% if s(1) ~= dft_length
%    error('number of rows should be fftsize/2+1')
% end
cols = s(2);

w_length = length(win);
h = floor(w_length/2);

x_length = dft_length + (cols-1)*h;
x = zeros(1,x_length);

for b = 0:h:(h*(cols-1))
  ft = d(:,1+b/h);
  u = ifft(ft);
  u = u';
  x((b+1):(b+dft_length)) = x((b+1):(b+dft_length))+ u(1:dft_length);
end;
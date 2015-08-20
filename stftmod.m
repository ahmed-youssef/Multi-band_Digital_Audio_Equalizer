function D = stftmod(x, dft_length, win)

if nargin < 2;  dft_length = 256; end
if nargin < 3;  win = ones(1,dft_length); end

% expect x as a row
if size(x,1) > 1
  x = x';
end

% expect win as a row
if size(win,1) > 1
  win = win';
end

x_length = length(x);
w_length = length(win);

% set hop
h = floor(w_length/4);

c = 1;

% pre-allocate output array
d = zeros(dft_length,1+fix((x_length-w_length)/h));

for i = 0:h:(x_length-w_length)
  u = win.*x((i+1):(i+w_length));
  u = u';
  d(:,c) = fft(u, dft_length); 
  c = c+1;
end;

  D = d;
end
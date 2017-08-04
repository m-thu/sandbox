% Quaternions (Matlab/Octave)

classdef Quaternion
	properties
		% Q = a + b i + c j + d k
		Q = [0 0 0 0];
	end

	properties (Dependent)
		Norm
		Conjugate
	end

	methods
		% Constructor
		function obj = Quaternion(q)
			if nargin > 0
				if isa(q, 'Quaternion')
					obj.Q = q.Q;
				else
					if (length(q) >=1) && (length(q) <= 4)
						obj.Q = [q, zeros(1, 4-length(q))];
					else
						error('Invalid length');
					end
				end
			end
		end

		% Override disp function
		function disp(obj)
			disp([num2str(obj.Q(1)), ' + ', ...
			      num2str(obj.Q(2)), 'i + ', ...
			      num2str(obj.Q(3)), 'j + ', ...
			      num2str(obj.Q(4)), 'k'])
		end

		% Getter for Norm property
		function val = get.Norm(obj)
			val = sqrt(obj.Q(1)^2 + obj.Q(2)^2 + obj.Q(3)^2 ...
			           + obj.Q(4)^2);
		end

		% Getter for Conjugate property
		function q = get.Conjugate(obj)
			q = Quaternion([obj.Q(1), -obj.Q(2), -obj.Q(3), ...
			               -obj.Q(4)]);
		end

		% Override binary plus
		function q = plus(q1, q2)
			q = Quaternion([q1.Q(1) + q2.Q(1), ...
			                q1.Q(2) + q2.Q(2), ...
					q1.Q(3) + q2.Q(3), ...
					q1.Q(4) + q2.Q(4)]);
		end

		% Override binary minus
		function q = minus(q1, q2)
			q = Quaternion([q1.Q(1) - q2.Q(1), ...
			                q1.Q(2) - q2.Q(2), ...
					q1.Q(3) - q2.Q(3), ...
					q1.Q(4) - q2.Q(4)]);
		end

		% Override unary plus
		function q = uplus(q1)
			q = Quaternion([q1.Q(1), q1.Q(2), q1.Q(3), ...
			                q1.Q(4)]);
		end

		% Override unary minus
		function q = uminus(q1)
			q = Quaternion([-q1.Q(1), -q1.Q(2), -q1.Q(3), ...
			                -q1.Q(4)]);
		end

		% Override multiplication
		function q = mtimes(q1, q2)
			q = Quaternion( ...
			    [q1.Q(1)*q2.Q(1)-q1.Q(2)*q2.Q(2)-q1.Q(3)*q2.Q(3)-q1.Q(4)*q2.Q(4),
			     q1.Q(1)*q2.Q(2)+q1.Q(2)*q2.Q(1)+q1.Q(3)*q2.Q(4)-q1.Q(4)*q2.Q(3),
			     q1.Q(1)*q2.Q(3)-q1.Q(2)*q2.Q(4)+q1.Q(3)*q2.Q(1)+q1.Q(4)*q2.Q(2),
			     q1.Q(1)*q2.Q(4)+q1.Q(2)*q2.Q(3)-q1.Q(3)*q2.Q(2)+q1.Q(4)*q2.Q(1)]);
		end
	end
end

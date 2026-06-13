<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\Admin\CreateRequestTypeRequest;
use App\Http\Requests\Api\Admin\UpdateRequestTypeRequest;
use App\Models\RequestType;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Str;

class RequestTypeController extends Controller
{
    /**
     * List all request types.
     */
    public function index(): JsonResponse
    {
        return response()->json(['data' => RequestType::all()]);
    }

    /**
     * Create a new request type.
     */
    public function store(CreateRequestTypeRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $validated['slug'] = $validated['slug'] ?? Str::slug($validated['name']);
        $validated['is_active'] = $validated['is_active'] ?? true;

        $requestType = RequestType::create($validated);

        return response()->json([
            'message' => 'Request type created successfully',
            'data'    => $requestType,
        ], 201);
    }

    /**
     * Update an existing request type.
     */
    public function update(UpdateRequestTypeRequest $request, RequestType $requestType): JsonResponse
    {
        $validated = $request->validated();

        if (isset($validated['name']) && !isset($validated['slug'])) {
            $validated['slug'] = Str::slug($validated['name']);
        }

        $requestType->update($validated);

        return response()->json([
            'message' => 'Request type updated successfully',
            'data'    => $requestType,
        ]);
    }

    /**
     * Toggle active status of a request type.
     */
    public function toggle(RequestType $requestType): JsonResponse
    {
        $requestType->update(['is_active' => !$requestType->is_active]);

        return response()->json([
            'message'   => 'Request type status toggled',
            'is_active' => $requestType->is_active,
        ]);
    }
}
